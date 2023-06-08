unit help_program;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus;

type

  { THelp_Form }

  THelp_Form = class(TForm)
    Screnshot: TImage;
    Instruction: TMemo;
    OK_Button: TButton;
    procedure OK_ButtonClick(Sender: TObject);
  private

  public

  end;

var
  Help_Form: THelp_Form;

implementation

{$R *.lfm}

{ THelp_Form }

procedure THelp_Form.OK_ButtonClick(Sender: TObject);
begin
  //Закрывать форму
  Close;
end;

end.

