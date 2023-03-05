unit gosa_program;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, BASS;

type

  { TForm1 }
  TPlayerMode = (Stop, Play, Paused);  //Нужно для определения состояния плеера
  TForm1 = class(TForm)
    Button_Last: TButton;
    Button_Stop: TButton;
    Button_Add_File: TButton;
    Button_Next: TButton;
    Name_Music: TLabel;
    TimePos: TLabel;
    Play_List: TListBox;
    OpenDialog1: TOpenDialog;
    Scroll_Bar_Music: TScrollBar;
    TimeLen: TLabel;
    Timer1: TTimer;
    Volume_Bar: TTrackBar;
    procedure Button_LastClick(Sender: TObject);
    procedure Button_StopClick(Sender: TObject);
    procedure Button_Add_FileClick(Sender: TObject);
    procedure Button_NextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Play_ListClick(Sender: TObject);
    procedure Scroll_Bar_MusicScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
   filename:UnicodeString;  //Путь песни
   channel:HSTREAM;         //Для сохранения песни в память
   Muz:integer;             //Номер песни относительно Плей листа
   Mode: TPlayerMode;       //Для определения в каком состоянии находится плеер(Play-производит песню, Paused-песня на паузе, Stop-песня застоплина и ожидается новая песня)
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button_StopClick(Sender: TObject);
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

procedure TForm1.Button_LastClick(Sender: TObject);
begin
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
  //Указываем какая щас песня по счету(Быстрей всего это времено)
      //Name_Music.Caption:=IntToStr(Muz+1);
  //Выделяем нужную нам строку в лист_боксе
  Play_List.ItemIndex:=Muz;
  //Записываем из путь песни из выделеной песни
  filename:=Play_List.Items[Muz];
  //Записываем путь песни в память
  channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
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

procedure TForm1.Button_Add_FileClick(Sender: TObject);
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
    Muz:=0;
  end;
end;

procedure TForm1.Button_NextClick(Sender: TObject);
begin
  //
  //Посмотри алгоритм действий у кнопки назад там все так же но только назад
  //
  if channel>0 then
  begin
    BASS_StreamFree(channel);
    channel:=0;
  end;
  Muz:=Muz+1;
  if Muz>Play_List.Items.Count-1 then Muz:=Play_List.Items.Count-1;
  Play_List.ItemIndex:=Muz;
  filename:=Play_List.Items[Muz];
  channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
  Scroll_Bar_Music.Min:=0;
  Scroll_Bar_Music.Max:=bass_ChannelGEtLength(Channel, 0)-1;
  BASS_ChannelPlay(channel,false);
  Mode:=Play;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //Останавливаем воспроизведение музыки
  Bass_Stop();
  //Очищаем память чтоб проблем всяких небыло
  BASS_Free();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Если плеер запустили то нужно...
  //Перевести плеер в состояние стопа или ожидания
  Mode:=Stop;
  //Указать трек бару минимальное значение
  Volume_Bar.Min:=0;
  //Указать трек бару максимальное значение
  Volume_Bar.Max:=10;
  //И указать где он должен находится по началу
  Volume_Bar.Position:=10;
  //Проверяем на то что работает ли у нас аудио
  if not BASS_Init(-1, 44100, 0, Handle, nil) then
  showmessage('Ошибка инициализации аудио');
end;

procedure TForm1.Play_ListClick(Sender: TObject);
begin
  //
  //Посмотри алгоритм действия у кнопки назад там все так же(надеюсь ты разберешься)
  //
  Muz:=Play_List.ItemIndex;
  filename:=Play_List.Items[Muz];
  //Поработай ещё с этим!!!!!
  {if Play_List.Items[Muz]='' then
  begin
    ShowMessage('Выберете файл!');
    Exit();
  end;}
  if channel>0 then
  begin
    BASS_StreamFree(channel);
    channel:=0;
  end;
  channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
  Scroll_Bar_Music.Min:=0;
  Scroll_Bar_Music.Max:=bass_ChannelGEtLength(Channel, 0)-1;
  BASS_ChannelPlay(channel,false);
  Mode:=Play;
end;

procedure TForm1.Scroll_Bar_MusicScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  //Это команда нужна для перемотки песни
  bass_ChannelSetPosition(Channel, Scroll_Bar_Music.position, 0);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
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
    if Muz>Play_List.Items.Count-1 then exit();
    Play_List.ItemIndex:=Muz;
    filename:=Play_List.Items[Muz];
    channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
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
