unit AnimateEasings;

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

{ TAnimateEasings }

type
  TAnimateEasings = class(TAnimate)
  private
    FRects: TArray<TRectF>;
    FIndex: Integer;
  public
    procedure GetInfo(out Name: string; out Description: string); override;
    procedure Draw(Params: TAnimateParams); override;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); override;
  end;

{ TAnimateEasings }

procedure TAnimateEasings.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Easings Demo';
  Description := 'An example animation of a few easing functions';
end;

procedure TAnimateEasings.Draw(Params: TAnimateParams);
const
  Mult: array[Boolean] of Float = (0, 1);
var
  B: IBrush;
  P: IPen;
  R, L: TRectF;
  T: Float;
  S: string;
  I: Integer;
begin
  Params.Surface.Rectangle(Params.Rect);
  Params.Surface.Fill(Brushes.Checker(clWhite, clSilver));
  B := NewBrush(clWhite);
  P := NewPen(clSteelBlue);
  R := TRectF.Create(200, 150);
  R.Offset(20, 20);
  T := Frac(Params.Time / 2);
  SetLength(FRects, Easings.Count);
  for I := 0 to Easings.Count - 1 do
  begin
    FRects[I] := R;
    Params.Surface.Rectangle(R);
    Params.Surface.Fill(B, True);
    if FIndex = I then
    begin
      P.Width := 4;
      P.LinePattern := pnDash;
      P.LinePatternOffset := Params.Time * -10;
    end
    else
    begin
      P.Width := 0.7;
      P.LinePattern := pnSolid;
    end;
    Params.Surface.Stroke(P);
    R.Inflate(-25, -25);
    S := Easings.Keys[I];
    DrawEasing(Params.Surface, Params.Font, R, Easings.Values[S],
      False, T * Mult[FIndex = I]);
    R.Inflate(25, 25);
    L := R;
    L.Top := L.Bottom - 25;
    Params.Font.Color := clBlack;
    Params.Surface.TextOut(Params.Font, S, L, drCenter);
    R.X := R.X + R.Width + 20;
    if R.Right > Params.Rect.Right - 20 then
    begin
      R.X := 20;
      R.Y := R.Bottom + 40;
    end;
  end;
end;

procedure TAnimateEasings.Mouse(X, Y: Integer; Kind: TMouseEventKind);
var
  I: Integer;
begin
  if Kind = mkDown then
    for I := 0 to Length(FRects) do
      if FRects[I].Contains(X, Y) then
      begin
        FIndex := I;
        Break;
      end;
end;

initialization
  RegisterAnimation(TAnimateEasings);
end.

