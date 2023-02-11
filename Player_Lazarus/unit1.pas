unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, BASS;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button2: TButton;
    Button3: TButton;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private

  public
   channel:HSTREAM;
  end;

var
  Form1: TForm1;
   filename:UnicodeString;
   Pause:bool;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
begin
  if Pause=False then
  begin
    BASS_Pause();
    Pause:=True;
  end
  else
  begin
    BASS_Start();
    Pause:=False;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i:Integer;
begin
      if OpenDialog1.Execute() then
      begin
        BASS_ChannelStop(channel);
        ListBox1.Items.Clear;
        for i:=0 to OpenDialog1.Files.Count-1 do
        begin
          ListBox1.Items.Add(OpenDialog1.Files[i]);
          ListBox1.Enabled:=true;
        end;
      end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  BASS_Free();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     if not BASS_Init(-1, 44100, 0, Handle, nil) then
  showmessage('Error initializing audio!');
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
    if channel>0 then
  begin
    BASS_StreamFree(channel);
    channel:=0;
  end;
  filename:=ListBox1.Items[ListBox1.ItemIndex];
channel:= BASS_StreamCreateFile(False,PWideChar(filename), 0, 0,BASS_UNICODE);
BASS_Stop();
Pause:=False;
BASS_ChannelPlay(channel,false);
end;


end.

