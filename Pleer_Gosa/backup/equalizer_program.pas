unit equalizer_program;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, BASS;

type

  { TEqualizer_Form }

  TEqualizer_Form = class(TForm)
    Close_Button: TButton;
    Label_80gz: TLabel;
    Label_14000gz: TLabel;
    Label_170gz: TLabel;
    Label_310gz: TLabel;
    Label_600gz: TLabel;
    Label_1000gz: TLabel;
    Label_3000gz: TLabel;
    Label_6000gz: TLabel;
    Label_10000gz: TLabel;
    Label_12000gz: TLabel;
    Timer1: TTimer;
    TrackBar_FX80: TTrackBar;
    TrackBar_FX14000: TTrackBar;
    TrackBar_FX170: TTrackBar;
    TrackBar_FX310: TTrackBar;
    TrackBar_FX600: TTrackBar;
    TrackBar_FX1000: TTrackBar;
    TrackBar_FX3000: TTrackBar;
    TrackBar_FX6000: TTrackBar;
    TrackBar_FX10000: TTrackBar;
    TrackBar_FX12000: TTrackBar;
    procedure Close_ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar_FX14000Change(Sender: TObject);
    procedure TrackBar_FX80Change(Sender: TObject);
    procedure TrackBar_FX170Change(Sender: TObject);
    procedure TrackBar_FX310Change(Sender: TObject);
    procedure TrackBar_FX600Change(Sender: TObject);
    procedure TrackBar_FX1000Change(Sender: TObject);
    procedure TrackBar_FX3000Change(Sender: TObject);
    procedure TrackBar_FX6000Change(Sender: TObject);
    procedure TrackBar_FX10000Change(Sender: TObject);
    procedure TrackBar_FX12000Change(Sender: TObject);
  private

  public

  end;

var
  Equalizer_Form: TEqualizer_Form;
  //переменные для настройки эквалайзера
  p: BASS_DX8_PARAMEQ;
  fx: array[1..10] of integer;
  Play: integer;

implementation

{$R *.lfm}

{ TEqualizer_Form }

procedure TEqualizer_Form.FormCreate(Sender: TObject);
begin
  Timer1.Interval:=10;
  TrackBar_FX80.Position:=10;
  TrackBar_FX170.Position:=10;
  TrackBar_FX310.Position:=10;
  TrackBar_FX600.Position:=10;
  TrackBar_FX1000.Position:=10;
  TrackBar_FX3000.Position:=10;
  TrackBar_FX6000.Position:=10;
  TrackBar_FX10000.Position:=10;
  TrackBar_FX12000.Position:=10;
  TrackBar_FX14000.Position:=10;
end;

procedure TEqualizer_Form.Timer1Timer(Sender: TObject);
begin
  //Если песня запущена
  if Play=1 then
  begin
    //Настройка первого канала эквалайзера
    p.fGain :=15-TrackBar_FX80.Position; //Усиление
    p.fBandwidth := 3; //Ширина полосы пропускания
    p.fCenter := 80; //Частота регулирования
    BASS_FXSetParameters(fx[1], @p);//Применение заданных настроек

    p.fGain := 15-TrackBar_FX170.Position;
    p.fBandwidth := 3;
    p.fCenter := 170;
    BASS_FXSetParameters(fx[2], @p);

    p.fGain := 15-TrackBar_FX310.Position;
    p.fBandwidth := 3;
    p.fCenter := 310;
    BASS_FXSetParameters(fx[3], @p);

    p.fGain := 15-TrackBar_FX600.Position;
    p.fBandwidth := 3;
    p.fCenter := 600;
    BASS_FXSetParameters(fx[4], @p);

    p.fGain := 15-TrackBar_FX1000.Position;
    p.fBandwidth := 3;
    p.fCenter := 1000;
    BASS_FXSetParameters(fx[5], @p);

    p.fGain := 15-TrackBar_FX3000.Position;
    p.fBandwidth := 3;
    p.fCenter := 3000;
    BASS_FXSetParameters(fx[6], @p);

    p.fGain := 15-TrackBar_FX6000.Position;
    p.fBandwidth := 3;
    p.fCenter := 6000;
    BASS_FXSetParameters(fx[7], @p);

    p.fGain := 15-TrackBar_FX10000.Position;
    p.fBandwidth :=3;
    p.fCenter := 10000;
    BASS_FXSetParameters(fx[8], @p);

    p.fGain := 15-TrackBar_FX12000.Position;
    p.fBandwidth := 3;
    p.fCenter := 12000;
    BASS_FXSetParameters(fx[9], @p);

    p.fGain := 15-TrackBar_FX14000.Position;
    p.fBandwidth := 3;
    p.fCenter := 14000;
    BASS_FXSetParameters(fx[10], @p);
    play:=0;
  end;
end;

procedure TEqualizer_Form.TrackBar_FX14000Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[10], @p);//Считываем параметры канала
  p.fgain := 15-TrackBar_FX14000.position;//Задаем усиление в зависимости от позиции TrackBar
  BASS_FXSetParameters(fx[10], @p);//Устанавливаем измененные параметры
end;

//Настройка для все остальных трек баров

procedure TEqualizer_Form.TrackBar_FX80Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[1], @p);
  p.fgain := 15-TrackBar_FX80.position;
  BASS_FXSetParameters(fx[1], @p);
end;

procedure TEqualizer_Form.TrackBar_FX170Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[2], @p);
  p.fgain := 15-TrackBar_FX170.position;
  BASS_FXSetParameters(fx[2], @p);
end;

procedure TEqualizer_Form.TrackBar_FX310Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[3], @p);
  p.fgain := 15-TrackBar_FX310.position;
  BASS_FXSetParameters(fx[3], @p);
end;

procedure TEqualizer_Form.TrackBar_FX600Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[4], @p);
  p.fgain := 15-TrackBar_FX600.position;
  BASS_FXSetParameters(fx[4], @p);
end;

procedure TEqualizer_Form.TrackBar_FX1000Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[5], @p);
  p.fgain := 15-TrackBar_FX1000.position;
  BASS_FXSetParameters(fx[5], @p);
end;

procedure TEqualizer_Form.TrackBar_FX3000Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[6], @p);
  p.fgain := 15-TrackBar_FX3000.position;
  BASS_FXSetParameters(fx[6], @p);
end;

procedure TEqualizer_Form.TrackBar_FX6000Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[7], @p);
  p.fgain := 15-TrackBar_FX6000.position;
  BASS_FXSetParameters(fx[7], @p);
end;

procedure TEqualizer_Form.TrackBar_FX10000Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[8], @p);
  p.fgain := 15-TrackBar_FX10000.position;
  BASS_FXSetParameters(fx[8], @p);
end;

procedure TEqualizer_Form.TrackBar_FX12000Change(Sender: TObject);
begin
  BASS_FXGetParameters(fx[9], @p);
  p.fgain := 15-TrackBar_FX12000.position;
  BASS_FXSetParameters(fx[9], @p);
end;

procedure TEqualizer_Form.Close_ButtonClick(Sender: TObject);
begin
  //Закрыть форму
  Close;
end;

end.

