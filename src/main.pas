unit Main;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Codebot.System,
  Codebot.Graphics,
  Codebot.Graphics.Types,
  Codebot.Animation,
  AnimateTools;

{ TAnimateForm }

type
  TAnimateForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
  private
    FTimer: TAnimationTimer;
    FAnimate: TAnimate;
    FAnimations: TAnimationList;
    FAnimationCount: Integer;
    FAnimationIndex: Integer;
    FPainted: Boolean;
    FSecond: Integer;
    FFrame: Integer;
    FFramePerSecond: Integer;
    procedure UpdateAnimation(Index: Integer);
    procedure TimerExpired(Sender: TObject);
  end;

var
  AnimateForm: TAnimateForm;

implementation

{$R *.lfm}

{ TAnimateForm }

procedure TAnimateForm.FormCreate(Sender: TObject);
begin
  RequestAnimations(FAnimations);
  FAnimationCount := Length(FAnimations);
  if FAnimationCount > 0 then
    UpdateAnimation(FAnimationCount - 1);
  FTimer := TAnimationTimer.Create(Self);
  FTimer.OnTimer := TimerExpired;
  FTimer.Enabled := True;
end;

procedure TAnimateForm.FormDestroy(Sender: TObject);
begin
  FAnimate.Free;
end;

procedure TAnimateForm.UpdateAnimation(Index: Integer);
begin
  if Index < 0 then
    Index := FAnimationCount - 1
  else if Index > FAnimationCount - 1 then
    Index := 0;
  FAnimationIndex := Index;
  FAnimate.Free;
  FAnimate := FAnimations[FAnimationIndex].Create;
  Caption := Format('Animation %d of %d', [FAnimationCount - FAnimationIndex, FAnimationCount]);
end;

procedure TAnimateForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
  VK_LEFT = 37;
  VK_RIGHT = 39;
begin
  if FAnimationCount < 2 then
    Exit;
  if Key = VK_LEFT then
    UpdateAnimation(FAnimationIndex + 1)
  else if Key = VK_RIGHT then
    UpdateAnimation(FAnimationIndex - 1);
end;

procedure TAnimateForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FAnimate <> nil then
    FAnimate.Mouse(X, Y, mkDown);
end;

procedure TAnimateForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FAnimate <> nil then
    FAnimate.Mouse(X, Y, mkMove);
end;

procedure TAnimateForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FAnimate <> nil then
    FAnimate.Mouse(X, Y, mkUp);
end;

procedure TAnimateForm.FormPaint(Sender: TObject);
var
  Params: TAnimateParams;
  R: TRectF;
  C: TColorB;
  Y, X1, X2: Float;
  N, D: string;
  I: Integer;
begin
  if WindowState = wsMinimized then
    Exit;
  if FAnimate <> nil then
  begin
    Params := TAnimateParams.Create;
    try
      Params.Surface := NewSurface(Canvas);
      Params.Rect := ClientRect;
      Params.Font := NewFont(Font);
      Params.Font.Color := clBlack;
      Params.Time := TimeQuery;
      I := Trunc(Params.Time);
      if I <> FSecond then
      begin
        FSecond := I;
        FFramePerSecond := FFrame;
        FFrame := 1;
      end
      else
        Inc(FFrame);
      FAnimate.Draw(Params);
      R := ClientRect;
      R.Inflate(-20, -20);
      FAnimate.GetInfo(N, D);
      Params.Font := NewFont(Font);
      Params.Font.SetStyle([fsBold]);
      Params.Font.Color := clBlack;
      X1 := Params.Surface.TextSize(Params.Font, N).X;
      Params.Font.SetStyle([]);
      X2 := Params.Surface.TextSize(Params.Font, D).X;
      if X1 > X2 then
        R.Width := X1 + 20
      else
        R.Width := X2 + 20;
      Params.Font.SetStyle([fsBold]);
      Y := Params.Surface.TextHeight(Params.Font, 'Wg', 1000);
      R.Top := R.Bottom - (Y * 2 + 20);
      R.Bottom := R.Top + Y * 2 + 20;
      Params.Surface.RoundRectangle(R, 20);
      C := clWhite;
      C.Alpha := $7F;
      Params.Surface.Fill(NewBrush(C));
      R.Left := R.Left + 10;
      R.Top := R.Top + 10;
      R.Bottom := R.Top + Y;
      Params.Surface.TextOut(Params.Font, N, R, drLeft);
      R.Top := R.Top + Y;
      R.Bottom := R.Top + Y;
      Params.Font.SetStyle([]);
      Params.Surface.TextOut(Params.Font, D, R, drLeft);
      R := ClientRect;
      R.Left := R.Right - 50;
      R.Top := R.Bottom - 30;
      Params.Surface.Rectangle(R);
      Params.Surface.Fill(NewBrush(clWhite));
      Params.Surface.TextOut(Params.Font, IntToStr(FFramePerSecond), R, drCenter);
    finally
      Params.Free;
    end;
    FPainted := False;
  end;
end;

procedure TAnimateForm.TimerExpired(Sender: TObject);
begin
  if not FPainted then
  begin
    FPainted := True;
    Invalidate;
  end;
end;

end.

