unit AnimateClipping;

{$mode delphi}

interface

implementation

uses
  Codebot.System,
  Codebot.Graphics,
  Codebot.Graphics.Types,
  Codebot.Animation,
  AnimateTools,
  Graphics;

{ TAnimateExample }

type

  { TAnimateClipping }

  TAnimateClipping = class(TAnimate)
  private
    FDirection: Integer;
    FDown: Boolean;
    FPoint: TPointF;
    FScale: TPointF;
  public
    constructor Create; override;
    procedure GetInfo(out Name: string; out Description: string); override;
    procedure Draw(Params: TAnimateParams); override;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); override;
  end;

constructor TAnimateClipping.Create;
begin
  inherited Create;
  FDirection := 1;
  FScale := TPointF.Create(1, 1);
end;

procedure TAnimateClipping.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Animated Clipping Example';
  Description := 'This is a demonstration of clipping';
end;

procedure TAnimateClipping.Draw(Params: TAnimateParams);
var
  B: IBrush;
begin
  Params.Surface.MoveTo(0, 0);
  Params.Surface.LineTo(Params.Rect.Right, 0);
  Params.Surface.LineTo(Params.Rect.Right, Params.Rect.Bottom);
  Params.Surface.LineTo(0, Params.Rect.Bottom);
  {Params.Surface.LineTo(0, 0);

  Params.Surface.LineTo(300, 500);
  Params.Surface.LineTo(700, 500);
  Params.Surface.LineTo(700, 300);
  Params.Surface.LineTo(500, 100);
  Params.Surface.LineTo(100, 100);
  Params.Surface.LineTo(300, 500);}

  Params.Surface.Path.Clip;

  B := Brushes.Checker(clGray, clMaroon);

  // B.Matrix.Translate(Params.Time * 50 * FDirection, 0);
  B.Matrix.Scale(FScale.X, FScale.Y);
  B.Matrix.Rotate(Params.Time / 10);
  Params.Surface.FillRect(B, Params.Rect);
end;

procedure TAnimateClipping.Mouse(X, Y: Integer; Kind: TMouseEventKind);
var
  P: TPointF;
begin
  P.X := X;
  P.Y := Y;
  if Kind = mkDown then
  begin
    FDirection := -FDirection;
    FDown := True;
    FPoint := P;
  end;
  if (Kind = mkMove) and FDown then
  begin
    FScale.X := (X - FPoint.X) / 100;
    FScale.Y := (Y - FPoint.Y) / 100;
    if FScale.X < 0.5 then
      FScale.X := 0.5;
    if FScale.Y < 0.5 then
      FScale.Y := 0.5;
  end;
  if Kind = mkUp then
  begin
    FDown := False;
  end;
end;

initialization
  RegisterAnimation(TAnimateClipping);
end.

