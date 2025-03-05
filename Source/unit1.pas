unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, IniFiles, ATStringProc_HtmlColor;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    StartDir, ConfigFile, ImageName, CounterColor, ErrorMessage: String;
    Seconds, CounterTop, COunterLeft: Integer;
    AllowClose: Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure read_ini(ConfigFile: String);
var
    ini: TIniFile;
    num1: Integer;
    ColorCito: TColor;
begin
    if ConfigFile = '' then begin
        Form1.ErrorMessage := 'Enter the path to the ini file using the parameter';
        Exit;
    end;

    if not FileExists(ConfigFile) then begin
        Form1.ErrorMessage := 'Ini file ' + ConfigFile + ' not found';
        Exit;
    end;

    ColorCito := clWhite;

    ini := TIniFile.Create(ConfigFile);
    Form1.AllowClose := ini.ReadBool('Main', 'AllowClose', True);
    Form1.Seconds := ini.ReadInteger('Main', 'Seconds', 60);
    Form1.ImageName := ini.ReadString('Main', 'Image', '');
    Form1.Label1.Top := ini.ReadInteger('Counter', 'Top', 0);
    Form1.Label1.Left := ini.ReadInteger('Counter', 'Left', 0);
    Form1.Label1.Font.Size := ini.ReadInteger('Counter', 'Size', 40);
    Form1.CounterColor := ini.ReadString('Counter', 'Color', '#FFFFFF');
    Form1.Label1.Font.Color := SHtmlColorToColor(Form1.CounterColor, num1, ColorCito);

    if not FileExists(Form1.ImageName) then begin
        Form1.AllowClose := False;
    end else begin
        Form1.Image1.Picture.LoadFromFile(Form1.ImageName);
        Form1.Image1.Width := Form1.Image1.Picture.Width;
        Form1.Image1.Height := Form1.Image1.Picture.Height;
        Form1.Width := Form1.Image1.Width;
        Form1.Height := Form1.Image1.Height;
    end;
    ini.Free;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
    StartDir := ExtractFilePath(ParamStr(0));
    if ParamStr(1) = ''
        then ConfigFile := StartDir + 'imsg.ini'
        else ConfigFile := ParamStr(1);
    read_ini(ConfigFile);
    if ErrorMessage <> '' then ShowMessage(ErrorMessage);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
    if ErrorMessage <> '' then begin
        AllowClose := True;
        Form1.Close;
    end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
    CanClose := AllowClose;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    dec(Seconds);
    Label1.Caption := IntToStr(Seconds);
    // на всякий случай восстанавливаем форму если пользователь ее свернул
    Application.Restore;
    Application.ProcessMessages;

    if (Seconds < 1) then begin
        AllowClose := True;
        Timer1.Enabled := False;;
        Form1.BorderStyle := bsSingle;
        Label1.Visible := False;
    end;
end;

end.

