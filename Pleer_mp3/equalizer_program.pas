unit equalizer_program;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  BASS;

type

  { TEqualizer_Form }

  TEqualizer_Form = class(TForm)
    Close_Button: TButton;
    TrackBar1: TTrackBar;
    TrackBar10: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    TrackBar8: TTrackBar;
    TrackBar9: TTrackBar;
    procedure Close_ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
  channel:HSTREAM;
  end;

var
  Equalizer_Form: TEqualizer_Form;
  //переменные для настройки эквалайзера
  p: BASS_DX8_PARAMEQ;
  fx: array[1..10] of integer;

implementation

{$R *.lfm}

{ TEqualizer_Form }

procedure TEqualizer_Form.FormCreate(Sender: TObject);
begin
  //настройка эквалайзера
    fx[1] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//первый канал эквалайзера
    fx[2] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);//второй канал
    fx[3] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[4] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[5] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[6] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[7] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[8] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[9] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
    fx[10] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
end;

procedure TEqualizer_Form.Close_ButtonClick(Sender: TObject);
begin
  Close;
end;

end.

