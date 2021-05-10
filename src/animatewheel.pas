unit AnimateWheel;

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

{ TAnimateWheel }

type
  TAnimateWheel = class(TAnimate)
  private
    FStart: Float;
    FSpinner: IBitmap;
    FAngle: Float;
    FPosition: Float;
    FSpin: Float;
    FDuration: Float;
    FKnob: TRectF;
    FHot: Boolean;
    FDrag: Boolean;
    FDragMin: Float;
    FDragMax: Float;
    FDragPos: Float;
    FDragRelease: Float;
    FCurrent: Integer;
    FPrior: Integer;
    FFadeTime: Float;
    FStopTime: Float;
    function CurrentColor: TColorB;
    function CurrentIndex: Integer;
    function CurrentNumber: Integer;
  public
    constructor Create; override;
    procedure GetInfo(out Name: string; out Description: string); override;
    procedure Draw(Params: TAnimateParams); override;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); override;
  end;

{ TAnimateWheel }

function SpinEasing(Percent: Float): Float;
begin
  Percent := 1 - Percent;
  Result := 1 - Percent * Percent * Percent;
end;

constructor TAnimateWheel.Create;
begin
  inherited Create;
  Randomize;
  FSpinner := NewBitmap;
  FSpinner.LoadFromFile('images/spinner.png');
  FStart := TimeQuery;
end;

const
  Circle = 2 * Pi;
  NumberCount = 24;
  Colors: array[0..7] of TColor = (
    $1266E7, $A4738B, $31D2CC, $A78ED3, $011DD1, $029BD1, $7D9732, $0FD331);
  ColorIndex: array[0..NumberCount - 1] of TColor = (
    0, 1, 2, 3, 4, 5, 6, 0, 7, 1, 2, 3, 7, 4, 1, 3, 6, 7, 1, 0, 2, 4, 5, 6);
  Numbers: array[0..NumberCount - 1] of Integer = (
    1, 14, 18, 4, 11, 6, 15, 22, 12, 3, 9, 20, 17, 7, 19, 23, 2, 16, 10, 5, 21,
    13, 8, 24);

function ColorFromNumber(N: Integer): TColorB;
var
  I: Integer;
begin
  for I := 0 to NumberCount - 1 do
    if Numbers[I] = N then
      Exit(TColorB(Colors[ColorIndex[I]]));
  Result := TColorB(clBlack);
end;

function TAnimateWheel.CurrentColor: TColorB;
begin
  Result := Colors[ColorIndex[CurrentIndex]];
end;

function TAnimateWheel.CurrentIndex: Integer;
var
  A: Float;
begin
  A := FPosition + Circle / (NumberCount * 2) + Circle;
  A := Remainder(A, Circle) / Circle;
  A := A * NumberCount;
  Result := Trunc(A);
end;

function TAnimateWheel.CurrentNumber: Integer;
begin
  Result := Numbers[CurrentIndex];
end;

procedure TAnimateWheel.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Spinning Wheel';
  Description := 'Try your luck and spin the wheel';
end;

procedure TAnimateWheel.Draw(Params: TAnimateParams);

  procedure DrawWheel;
  const
    Arrow = 20;
    Offset = 250;
    Shadow = 5;
    SpinFactor = 1.5;
  var
    C: TColorB;
    G: IGradientBrush;
    R: TRectF;
  begin
    if FDuration > 0 then
    begin
      if Params.Time - FSpin > FDuration then
      begin
        FAngle := Remainder(FAngle + FDuration * SpinFactor, 2 * Pi);
        FDuration := 0;
        FStopTime := Params.Time;
        FPosition := FAngle;
      end
      else
        FPosition := Interpolate(SpinEasing, (Params.Time - FSpin) / FDuration,
          FAngle, FAngle + FDuration * SpinFactor);
    end
    else
      FPosition := FAngle;
    G := NewBrush(0, 0, 0, Params.Rect.Height);
    G.AddStop(clGreen, 0);
    G.AddStop(TColorB(clGreen).Darken(0.5), 1);
    Params.Surface.Rectangle(Params.Rect);
    Params.Surface.Fill(G);
    R := FSpinner.ClientRect;
    Params.Surface.Matrix.Translate(-R.Width / 2, -R.Height / 2);
    Params.Surface.Matrix.Rotate(-FPosition);
    Params.Surface.Matrix.Translate(Params.Rect.Width / 2, Params.Rect.Height + Offset);
    FSpinner.Surface.CopyTo(R, Params.Surface, R);
    Params.Surface.Matrix.Identity;
    R.X := Params.Rect.Width / 2 - Arrow;
    R.Width := Arrow * 2;
    R.Y := Params.Rect.Height - Offset / 2 - Arrow + 5;
    R.Height := Arrow * 1.5;
    Params.Surface.MoveTo(R.X + Shadow, R.Y + Shadow);
    Params.Surface.LineTo(R.Right + Shadow, R.Y + Shadow);
    Params.Surface.LineTo(R.MidPoint.X + Shadow, R.Bottom + Shadow);
    Params.Surface.Path.Close;
    Params.Surface.Fill(NewBrush(TColorB(clBlack).Fade(0.2)));
    Params.Surface.MoveTo(R.X, R.Y);
    Params.Surface.LineTo(R.Right, R.Y);
    Params.Surface.LineTo(R.MidPoint.X, R.Bottom);
    Params.Surface.Path.Close;
    Params.Surface.Fill(NewBrush(CurrentColor), True);
    C := TColorB(clBlack).Lighten(0.1);
    if FDuration > 0 then
      C := C.Blend(TColorB(clBlack).Lighten(0.7), (Sin((Params.Time - FSpin) * 10) + 1) / 2);
    Params.Surface.Stroke(NewPen(C, 3));
    if FCurrent <> CurrentNumber then
    begin
      FPrior := FCurrent;
      FCurrent := CurrentNumber;
      FFadeTime := Params.Time;
    end;
  end;

  procedure DrawHandle;
  const
    Indent = 40;
    Width = 20;
  var
    R: TRectF;
    C: TColorB;
    G: IGradientBrush;
    H, P: Float;
  begin
    R := Params.Rect;
    R.Inflate(-Indent, -Indent);
    R.X := R.Right - Width;
    R.Width := Width;
    Params.Surface.RoundRectangle(R, Width / 2);
    Params.Surface.Fill(NewBrush(TColorB(clWhite).Fade(0.1)), True);
    Params.Surface.Stroke(NewPen(TColorB(clBlack).Fade(0.2), 1));
    FDragMin := R.Y + Width / 2;
    FDragMax := R.Bottom - Width / 2;
    H := R.Height - Width;
    R.Y := R.Y + FDragPos * H;
    R.Height := R.Width;
    if FDuration > 0 then
    begin
      P := Clamp((Params.Time - FSpin));
      R.Y := R.Y + FDragRelease * H - FDragRelease * H * Easings['Bounce'](P);
    end;
    G := NewBrush(R.X + R.Width / 4, R.Y, R.Right - R.Width / 4, R.Bottom);
    G.AddStop(TColorB(clBlack).Lighten(0.5), 0);
    G.AddStop(TColorB(clBlack).Lighten(0.8), 0.5);
    G.AddStop(TColorB(clBlack).Lighten(0.25), 1);
    Params.Surface.Ellipse(R);
    Params.Surface.Fill(G, True);
    FKnob := R;
    if FDuration > 0 then
    begin
      C := TColorB(clBlack).Lighten(0.1);
      C := C.Blend(TColorB(clBlack).Lighten(0.7), (Sin((Params.Time - FSpin) * 10) + 1) / 2);
      Params.Surface.Stroke(NewPen(C, 2));
    end
    else
    if FDrag then
    begin
      C := clSteelBlue;
      C := C.Blend(TColorB(clRed).Lighten(0.2), FDragPos);
      Params.Surface.Stroke(NewPen(C, 2));
    end
    else if FHot then
    begin
      Params.Surface.Stroke(NewPen(clSteelBlue, 2));
    end
    else
      Params.Surface.Stroke(NewPen(TColorB(clBlack).Lighten(0.4)));
  end;

  procedure DrawGrid;
  const
    Fade = 0.2;
    Size = 100;
    Space = 30;
  var
    E: TEasing;
    F: IFont;
    C: TColorB;
    G: IGradientBrush;
    BlackBrush: IBrush;
    WhitePen, FadePen: IPen;
    WhiteBrush, FadeBrush: IBrush;
    M: Float;
    R, B: TRectF;
    X, Y: Float;
    I: Integer;
  begin
    E := Easings['Easy'];
    R.Width := Size;
    R.Height := Size;
    R.X := (Params.Rect.Width + Size * -6 + Space * -5) / 2;
    R.Y := (Params.Rect.Height - 250) / 2 + 50 - Size * 2 - Space * 2;
    F := NewFont;
    F.Style := [fsBold];
    F.Size := R.Height / 2.5;
    BlackBrush := NewBrush(clBlack);
    WhitePen := NewPen(clWhite, 3);
    FadePen := NewPen(TColorB(clWhite).Darken(0.3), 3);
    WhiteBrush := NewBrush(clWhite);
    FadeBrush := NewBrush(TColorB(clWhite).Darken(0.3));
    B := R;
    for I := 1 to NumberCount do
    begin
      X := B.X;
      Y := B.Y;
      Params.Surface.Ellipse(B);
      if (FDuration = 0) and (I = FCurrent) then
      begin
        M := Params.Time - FStopTime;
        M := (Sin(M * 5) + 1) / 2;
        Params.Surface.Fill(NewBrush(TColorB(clBlack).Lighten(0.5 * M)));
      end
      else
        Params.Surface.Fill(BlackBrush);
      B.Inflate(-4, -4);
      Params.Surface.Ellipse(B);
      if (I = FPrior) and (Params.Time - FFadeTime < Fade) then
      begin
        M := E((Params.Time - FFadeTime) / Fade) * 0.3;
        C := clWhite;
        C := C.Darken(M);
        Params.Surface.Fill(NewBrush(C));
      end
      else if (I = FCurrent) and (Params.Time - FFadeTime < Fade) then
      begin
        C := TColorB(clWhite).Darken(0.3);
        M := E((Params.Time - FFadeTime) / Fade);
        C := C.Lighten(M);
        Params.Surface.Fill(NewBrush(C));
      end
      else if I = FCurrent then
        Params.Surface.Fill(WhiteBrush)
      else
        Params.Surface.Fill(FadeBrush);
      B.Inflate(-3, -3);
      Params.Surface.Ellipse(B);
      Params.Surface.Fill(BlackBrush);
      B.Inflate(-2, -2);
      Params.Surface.Ellipse(B);
      if (I = FPrior) and (Params.Time - FFadeTime < Fade) then
      begin
        G := NewBrush(B);
        M := E((Params.Time - FFadeTime) / Fade);
        C := ColorFromNumber(I);
        G.AddStop(C.Lighten(0.7).Blend(C.Darken(0.5), M) , 0);
        G.AddStop(C.Blend(C.Darken(0.5), M) , 1);
        Params.Surface.Fill(G);
      end
      else if (I = FCurrent) and (Params.Time - FFadeTime < Fade) then
      begin
        G := NewBrush(B);
        M := 1 - E((Params.Time - FFadeTime) / Fade);
        C := ColorFromNumber(I);
        G.AddStop(C.Lighten(0.7).Blend(C.Darken(0.5), M) , 0);
        G.AddStop(C.Blend(C.Darken(0.5), M) , 1);
        Params.Surface.Fill(G);
      end
      else if I = FCurrent then
      begin
        G := NewBrush(B);
        C := ColorFromNumber(I);
        G.AddStop(C.Lighten(0.7), 0);
        G.AddStop(C, 1);
        Params.Surface.Fill(G);
      end
      else
        Params.Surface.Fill(NewBrush(ColorFromNumber(I).Darken(0.5)));
      B.Offset(3, 3);
      Params.Surface.TextOut(F, IntToStr(I), B, drCenter, False);
      Params.Surface.Fill(NewBrush(TColorB(clBlack).Fade(0.5)));
      B.Offset(-3, -3);
      Params.Surface.TextOut(F, IntToStr(I), B, drCenter, False);
      if I = FCurrent then
        Params.Surface.Stroke(WhitePen, True)
      else
        Params.Surface.Stroke(FadePen, True);
      Params.Surface.Fill(BlackBrush);
      if I mod 6 = 0 then
      begin
        B.X := R.X;
        B.Y := Y  + Size + Space;
      end
      else
      begin
        B.X := X + Size + Space;
        B.Y := Y;
      end;
      B.Width := Size;
      B.Height := Size;
    end;
  end;

begin
  DrawWheel;
  DrawHandle;
  DrawGrid;
end;

procedure TAnimateWheel.Mouse(X, Y: Integer; Kind: TMouseEventKind);
begin
  if FDuration > 0 then
    Exit;
  case Kind of
    mkMove:
      if FDrag then
      begin
        FDragPos := Clamp((Y - FDragMin) / (FDragMax - FDragMin));
      end
      else
        FHot := FKnob.Contains(X, Y);
    mkDown:
      if FKnob.Contains(X, Y) then
      begin
        FDrag := True;
        FDragPos := Clamp((Y - FDragMin) / (FDragMax - FDragMin));
      end;
    mkUp:
      if FDrag then
      begin
        FDragPos := Clamp((Y - FDragMin) / (FDragMax - FDragMin));
        if FDragPos > 0.15 then
        begin
          FDragRelease := FDragPos;
          FSpin := TimeQuery;
          FDuration := 5 + Random * 5 + 8 * FDragPos;
        end;
        FDragPos := 0;
        FDrag := False;
        FHot := False;
      end;
  end;
end;

initialization
  Easings['Spin'] := SpinEasing;
  RegisterAnimation(TAnimateWheel);
end.

