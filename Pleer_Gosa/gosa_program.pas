unit gosa_program;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, BASS, help_program, equalizer_program;

type

  { TPleer_Form }
  TPlayerMode = (Stop, Play, Paused);  //Нужно для определения состояния плеера
  TVolumeBarMode = (Hidde, Showe);     //Для скрытия звукового бара
  TPleer_Form = class(TForm)
    Equalizer_Button: TButton;
    HelpButton: TButton;
    Hide_Show_Button: TButton;
    Button_Last: TButton;
    Button_Add_File: TButton;
    Button_Next: TButton;
    Button_Play_Paused: TImage;
    Name_Music: TLabel;
    TimePos: TLabel;
    Play_List: TListBox;
    OpenDialog1: TOpenDialog;
    Scroll_Bar_Music: TScrollBar;
    TimeLen: TLabel;
    Timer1: TTimer;
    Volume_Bar: TTrackBar;
    procedure Equalizer_ButtonClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure Hide_Show_ButtonClick(Sender: TObject);
    procedure Button_LastClick(Sender: TObject);
    procedure Button_Add_FileClick(Sender: TObject);
    procedure Button_NextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button_Play_PausedClick(Sender: TObject);
    procedure Button_Play_PausedMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_Play_PausedMouseEnter(Sender: TObject);
    procedure Button_Play_PausedMouseLeave(Sender: TObject);
    procedure Button_Play_PausedMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Play_ListClick(Sender: TObject);
    procedure Scroll_Bar_MusicScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Pleer_Form: TPleer_Form;
   filename:UnicodeString;  //Путь песни
   channel:HSTREAM;         //Для сохранения песни в память
   Muz:integer;             //Номер песни относительно Плей листа
   Mode: TPlayerMode;       //Для определения в каком состоянии находится плеер(Play-производит песню, Paused-песня на паузе, Stop-песня застоплина и ожидается новая песня)
   Bar: TVolumeBarMode;     //Для определения открыт открыт ли трек бар
implementation

{$R *.lfm}

procedure Play_player();//Для настройки эквалайзера
begin
  equalizer_program.fx[1] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//первый канал эквалайзера
  equalizer_program.fx[2] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//второй канал
  equalizer_program.fx[3] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//третий канал
  equalizer_program.fx[4] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//четвертый канал
  equalizer_program.fx[5] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//пятый канал
  equalizer_program.fx[6] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//шестой канал
  equalizer_program.fx[7] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//седьмой канал
  equalizer_program.fx[8] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//восьмой канал
  equalizer_program.fx[9] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//девятый канал
  equalizer_program.fx[10] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//десятый канал
  equalizer_program.Play:=1;                                                     //передача настроек эквалайзера
end;

{ TPleer_Form }

procedure TPleer_Form.Button_LastClick(Sender: TObject);
begin
  //Проверем на пустой ли плейлист чтоб не вызвало лишних ошибок
  if Play_List.Items.Count=0 then Exit;
  //Проверяемм запущен ли трек на данный момент если да то очищаем память и переменную
  if channel>0 then
  begin
    BASS_StreamFree(channel);
    channel:=0;
  end;
  //Уменьшаем переменую для того чтоб поднятся на строчку выше
  Muz:=Muz-1;
  //Проверяем не перешли мы предел(Для того чтоб программа не сломалась)
  if Muz<0 then Muz:=0;
  //Выделяем нужную нам строку в лист_боксе
  Play_List.ItemIndex:=Muz;
  //Записываем из путь песни из выделеной песни
  filename:=Play_List.Items[Muz];
  //Записываем музыкальный файл в память
  channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
  //Вызываем процедуру настройки эквалайзера
  Play_player;
  //Указываем минимальную точку в скрол баре
  Scroll_Bar_Music.Min:=0;
  //Указываем максимальную точку в скрол баре(нужно для
  //того чтоб скрол бар работал нормально)
  Scroll_Bar_Music.Max:=bass_ChannelGEtLength(Channel, 0)-1;
  //И запускаем песню
  BASS_ChannelPlay(channel,false);
  //Указываем что у нас плеер находится в состоянии воспроизведения
  Mode:=Play;
end;

procedure TPleer_Form.Hide_Show_ButtonClick(Sender: TObject);
begin
  //Если скролбар громкости музыки скрыты то
  if Bar=hidde then
  begin
    //То выводим скролбар на экран
    Volume_Bar.Show;
    //Переводим скрол бар в режим показывания
    Bar:=Showe;
    //И выходим из процедуры чтоб не было ошибки как при паузе
    Exit();
  end;
  //Если скролбар громкости музыки показывается на экран то
  if Bar=showe then
  begin
    //Скрываем его с экрана
    Volume_Bar.Hide;
    //Переводим его в режим скрытости
    Bar:=Hidde;
    //И выходим(чтоб точно не было ошибок)
    Exit();
  end;
end;

procedure TPleer_Form.HelpButtonClick(Sender: TObject);
begin
  //Выводим окно инструкции на экран
  Help_Form.Show;
end;

procedure TPleer_Form.Equalizer_ButtonClick(Sender: TObject);
begin
  //Выводим окно эквалайзера на экран
  Equalizer_Form.Show;
end;

procedure TPleer_Form.Button_Add_FileClick(Sender: TObject);
var
  i:Integer;
begin
  if OpenDialog1.Execute() then
  begin
    BASS_ChannelStop(channel);
    Play_List.Items.Clear;
    for i:=0 to OpenDialog1.Files.Count-1 do
    begin
      Play_List.Items.Add(OpenDialog1.Files[i]);
      Play_List.Enabled:=true;
    end;
  end;
  if channel>0 then
  begin
    BASS_StreamFree(channel);
    channel:=0;
  end;
  Mode:=Stop;
  Muz:=0;
  Scroll_Bar_Music.Position:=0;
  TimePos.Caption:='00:00:00';
  TimeLen.Caption:='00:00:00';
  Name_Music.Caption:='Выберете музыку';
end;

procedure TPleer_Form.Button_NextClick(Sender: TObject);
begin
  //
  //Посмотри алгоритм действий у кнопки назад там все так же но только назад
  //
  if Play_List.Items.Count=0 then Exit;
  if channel>0 then
  begin
    BASS_StreamFree(channel);
    channel:=0;
  end;
  Muz:=Muz+1;
  if mode=stop then
    Muz:=0;
  if Muz>Play_List.Items.Count-1 then Muz:=Play_List.Items.Count-1;
  Play_List.ItemIndex:=Muz;
  filename:=Play_List.Items[Muz];
  channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
  Play_player;
  Scroll_Bar_Music.Min:=0;
  Scroll_Bar_Music.Max:=bass_ChannelGEtLength(Channel, 0)-1;
  BASS_ChannelPlay(channel,false);
  Mode:=Play;
end;

procedure TPleer_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //Останавливаем воспроизведение музыки
  Bass_Stop();
  //Очищаем память чтоб проблем всяких небыло
  BASS_Free();
end;

procedure TPleer_Form.FormCreate(Sender: TObject);
begin
  //Если плеер запустили то нужно...
  //Перевести плеер в состояние стопа или ожидания
  Mode:=Stop;

  Button_Play_Paused.Picture.LoadFromFile('pause.png');
  //Указать трек бару минимальное значение
  Volume_Bar.Min:=0;
  //Указать трек бару максимальное значение
  Volume_Bar.Max:=10;
  //И указать где он должен находится по началу
  Volume_Bar.Position:=10;
  //Скрываем волуме бар
  Volume_Bar.Hide;
  //Переключаем состояние волуме бара
  Bar:=Hidde;
  //Проверяем на то что работает ли у нас аудио
  if not BASS_Init(-1, 44100, 0, Handle, nil) then
  showmessage('Ошибка инициализации аудио');
end;

procedure TPleer_Form.Button_Play_PausedClick(Sender: TObject);
begin
  //Для начало проверяем в каком состоянии находится плеер
  //Если он включен то должны...
  if Mode=Play then
  begin
    //Запаузить поток
    BASS_ChannelPause(Channel);
    //Переключит состояние плеера на паузу
    Mode:=Paused;
    //И выйти из цикла тк ниже по коду встречается условие на которое не нужно поподать
    Exit();
  end;
  //Если он запаузен то должны
  if Mode=Paused then
  begin
    //Востановить поток
    BASS_ChannelPlay(Channel,false);
    //И перевести плеер в состояние воспроизведения
    Mode:=Play;
  end;
end;

procedure TPleer_Form.Button_Play_PausedMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Mode <> Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('pause_click.png');
  end;
  if Mode=Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('play_click.png');
  end;
end;

procedure TPleer_Form.Button_Play_PausedMouseEnter(Sender: TObject);
begin
  if Mode <> Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('pause_mouse_down.png');
  end;
  if Mode=Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('play_mouse_down.png');
  end;
end;

procedure TPleer_Form.Button_Play_PausedMouseLeave(Sender: TObject);
begin
  if Mode <> Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('pause.png');
  end;
  if Mode=Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('play.png');
  end;
end;

procedure TPleer_Form.Button_Play_PausedMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Mode <> Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('pause_mouse_down.png');
  end;
  if Mode=Paused then
  begin
    Button_Play_Paused.Picture.LoadFromFile('play_mouse_down.png');
  end;
end;

procedure TPleer_Form.Play_ListClick(Sender: TObject);
begin
  //Указываем в переменую какая строчка ща выбрана
  Muz:=Play_List.ItemIndex;
  //Если выбрана пустая строка из плейлиста то выходим процедуры чтоб небыло ошибки
  if Muz<0 then
  begin
    //Показываем сообщение пользователю
    ShowMessage('Выберете файл!');
    //Выходим
    Exit();
  end;
  //Записываем строчку в переменую
  filename:=Play_List.Items[Muz];
  //Проверяем если что то в памяти
  if channel>0 then
  begin
    //Очищаем память
    BASS_StreamFree(channel);
    //Очищаем переменую
    channel:=0;
  end;
  //Записываем в память музыкальный файл
  channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
  //Настраиваем эквалайзер
  Play_player;
  //Указываем минимальную точку в скрол баре
  Scroll_Bar_Music.Min:=0;
  //Указываем максимальную точку в скрол баре
  Scroll_Bar_Music.Max:=bass_ChannelGEtLength(Channel, 0)-1;
  //Запускаем музыкальный файл
  BASS_ChannelPlay(channel,false);
  //Переводит музыкальный плеер в состояние проигрывания
  Mode:=Play;
end;

procedure TPleer_Form.Scroll_Bar_MusicScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  //Это команда нужна для перемотки песни
  bass_ChannelSetPosition(Channel, Scroll_Bar_Music.position, 0);
end;

procedure TPleer_Form.Timer1Timer(Sender: TObject);
var
TrackLen, TrackPos: Double; //Определяют позицию в треке но всекундах
ValPos, ValLen: Double; //Показывают время но уже в часах
Name_Muz: string;  //Строка для название песен
Delet_Simvol, i: integer;  //Переменые для цикла и определение место нахождения символа
begin
  //Проверяем играет песня и как видно если она не играет то значит выходим из процедуры
  if mode<>play then
    exit();
  //Проверяем закончился ли трек если до переходим на следуйщий
  if BASS_ChannelIsActive(channel)=BASS_ACTIVE_STOPPED then
  begin
    //Алгоритм действий такой же как и у кнопки вперед только...
    Muz:=Muz+1;
    //Если дальше нет песен то выходим из процедуры таймер
    if Muz>Play_List.Items.Count-1 then
    begin
      Muz:=Muz-1;
      Mode:=Stop;
      exit();
    end;
    //
    //Смотри на алгоритм действий кнопки назад или же на нажатие бокс листа
    //
    Play_List.ItemIndex:=Muz;
    filename:=Play_List.Items[Muz];
    channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
    Play_player;
    Scroll_Bar_Music.Min:=0;
    Scroll_Bar_Music.Max:=bass_ChannelGEtLength(Channel, 0)-1;
    BASS_ChannelPlay(channel,false);
    Mode:=Play;
  end;

  //Устанавливаем позицию скролбара зависимо от песни
  Scroll_Bar_Music.Position:=bass_channelGetPosition(channel,0);

  //Название песни метки
  //Открываем цикл для того чтоб найти с кого символа начинается название файла
  for i:=length(Filename) downto 1 do
  begin
     //Если мы находим начало название файла то...
     if Filename[i]='\' then
     begin
       //Записываем на каком символе это начинается
       Delet_Simvol:=i;
       //И выходим из цикла
       break;
     end;
  end;
  //Готовим почву для занесения имя файла
  Name_Muz:='Сейчас играет: '+IntToStr(Muz+1)+'. ';
  //Опять же открываем цикл но уже для того чтоб записать имя файла в финальную строку
  for i:=1 to length(Filename) do
  begin
    //Если мы доходим до того когда начинается название файла без всякого мусора то...
    if i>Delet_Simvol then
    begin
      //Записываем по символьно в финальную строку
      Name_Muz:=Name_Muz+Filename[i];
    end;
  end;
  Name_Music.Caption:='';
  if Length(Name_Muz)>60 then
  begin
    for i:=1 to 60 do
      Name_Music.Caption:=Name_Music.Caption+Name_Muz[i];
    Name_Music.Caption:=Name_Music.Caption+'...';
  end
  else
    //Выводим финальную строку
    Name_Music.Caption:=Name_Muz;
  //Время для меток
  //Считывает сколько времяни прошло от начало песни
  TrackPos:=BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0));
  //Считывает всю продолжительность песни
  TrackLen:=BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel,0));
  //Переводим секунды в часы
  ValPos:=TrackPos / (24 * 3600);
  ValLen:=TrackLen / (24 * 3600);
  //И выводим все это на экран(точнее на лэйбел Таймпоз и Таймлен)
  TimePos.Caption:=FormatDateTime('hh:mm:ss',ValPos);
  TimeLen.Caption:=FormatDateTime('hh:mm:ss',ValLen);
  //Подстраивает звук под трек бар
  BASS_ChannelSetAttribute(Channel,BASS_ATTRIB_VOL, Volume_Bar.Position/10);
end;

end.
