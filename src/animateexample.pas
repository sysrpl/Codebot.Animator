unit AnimateExample;

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
  TAnimateExample = class(TAnimate)
  private
    FDown: Boolean;
    FGrabIndex: Integer;
    FStart, FFinish, FC1, FC2: TPointF;
  public
    procedure GetInfo(out Name: string; out Description: string); override;
    procedure Draw(Params: TAnimateParams); override;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); override;
  end;

procedure TAnimateExample.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Name';
  Description := 'Description';
end;

procedure TAnimateExample.Draw(Params: TAnimateParams);
var
  Bitmap: IBitmap;
  Brush: IBrush;
  Pen: IPen;
  R: TRectF;
begin
  Bitmap := NewBitmap(50, 50);
  Bitmap.Surface.Rectangle(Bitmap.ClientRect);
  Bitmap.Surface.Fill(NewBrush(clSilver));
  Bitmap.Surface.MoveTo(0, 50);
  Bitmap.Surface.LineTo(0, 0);
  Bitmap.Surface.LineTo(50, 0);
  Pen := NewPen(clGray, 2);
  Pen.LinePattern := pnDash;
  Bitmap.Surface.Stroke(Pen);
  Brush := NewBrush(Bitmap);
  Params.Surface.Rectangle(Params.Rect);
  Params.Surface.Fill(Brush);
  Params.Surface.MoveTo(FStart.X, FStart.Y);
  Params.Surface.CurveTo(FFinish.X, FFinish.Y, FC1, FC2);
  Pen := NewPen(clBlack, 5);
  Pen.LineCap := cpRound;
  Params.Surface.Stroke(Pen);
  R := TRectF.Create(10, 10);
  R.Center(FStart);
  Params.Surface.Ellipse(R);
  Brush := NewBrush(clSilver);
  Pen := NewPen(clBlack, 2);
  Params.Surface.Fill(Brush, True);
  Params.Surface.Stroke(Pen);
  R.Center(FFinish);
  Params.Surface.Ellipse(R);
  Params.Surface.Fill(Brush, True);
  Params.Surface.Stroke(Pen);
  Params.Surface.MoveTo(FStart.X, FStart.Y);
  Params.Surface.LineTo(FC1.X, FC1.Y);
  Pen := NewPen(clGreen, 1);
  Params.Surface.Stroke(Pen);
  R.Center(FC1);
  Params.Surface.Ellipse(R);
  Params.Surface.Fill(Brush, True);
  Params.Surface.Stroke(Pen);
  Params.Surface.MoveTo(FFinish.X, FFinish.Y);
  Params.Surface.LineTo(FC2.X, FC2.Y);
  Params.Surface.Fill(Brush, True);
  Params.Surface.Stroke(Pen);
  R.Center(FC2);
  Params.Surface.Ellipse(R);
  Params.Surface.Fill(Brush, True);
  Params.Surface.Stroke(Pen);
end;

procedure TAnimateExample.Mouse(X, Y: Integer; Kind: TMouseEventKind);
const
  Grab = 10;
var
  P: TPointF;
begin
  P.X := X;
  P.Y := Y;
  if Kind = mkDown then
  begin
    FDown := True;
    if FC1.Dist(P) < Grab then
      FGrabIndex := 2
    else if FC2.Dist(P) < Grab then
      FGrabIndex := 3
    else if FStart.Dist(P) < Grab then
      FGrabIndex := 0
    else if FFinish.Dist(P) < Grab then
      FGrabIndex := 1
    else
      FGrabIndex := -1;
    if FGrabIndex < 0 then
    begin
      FStart.X := X;
      FStart.Y := Y;
      FC1 := FStart;
      FFinish := FStart;
      FC2 := FFinish;
    end;
  end
  else if (Kind = mkMove) and FDown then
  begin
    case FGrabIndex of
      0: FStart := P;
      1: FFinish := P;
      2: FC1 := P;
      3: FC2 := P;
    else
      FC2 := FFinish;
      FFinish.X := X;
      FFinish.Y := Y;
    end;
  end
  else if (Kind = mkUp) and FDown then
  begin
    FGrabIndex := -1;
    FDown := False;
  end;
end;

initialization
  // RegisterAnimation(TAnimateExample);
end.

