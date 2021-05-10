unit AnimatePaint;

{$mode delphi}

interface

implementation

uses
  Codebot.System,
  Codebot.Graphics,
  Codebot.Graphics.Types,
  Codebot.Animation,
  Codebot.Geometry,
  AnimateTools,
  Graphics;

type
  TShape = record
    Point: TPointF;
    Time: Float;
    V0, V1, V2: TPointF;
    procedure Draw(S: ISurface; T: Float; out Done: Boolean);
    procedure Generate(P: TPointF; T: Float);
  end;

  TShapes = TArrayList<TShape>;

var
  Rubber: TEasing;

procedure TShape.Draw(S: ISurface; T: Float; out Done: Boolean);
const
  Fade = 0.5;
var
  P: Float;
begin
  T := T - Time;
  if T < 0.01 then
    Exit;
  if T < Fade then
  begin
    P := Rubber(T / Fade);
    Done := False;
  end
  else
  begin
    P := 1;
    Done := True;
  end;
  S.MoveTo(V0.X * P + Point.X, V0.Y * P + Point.Y);
  S.LineTo(V1.X * P + Point.X, V1.Y * P + Point.Y);
  S.LineTo(V2.X * P + Point.X, V2.Y * P + Point.Y);
  S.Path.Close;
end;


procedure TShape.Generate(P: TPointF; T: Float);
const
  Scale = 20;
  Jitter = 50;
var
  M: TMatrix;
  V: TVec3;
  S: Float;
begin
  S := Random * Scale + 2;
  P.X := P.X + (Random * Jitter) - Jitter / 2;
  P.Y := P.Y + (Random * Jitter) - Jitter / 2;
  Point := P;
  Time := T;
  M.Identity;
  M.Rotate(0, 0, Random * 360);
  V.X := 0; V.Y:= -1 * S;
  V := M * V;
  V0.X := V.X; V0.Y := V.Y;
  V.X := 0.8 * S; V.Y:= 0.6 * S;
  V := M * V;
  V1.X := V.X; V1.Y := V.Y;
  V.X := 0.8 * -S; V.Y:= 0.6 * S;
  V := M * V;
  V2.X := V.X; V2.Y := V.Y;
end;

{ TAnimatePaint }

type
  TAnimatePaint = class(TAnimate)
  private
    FDrawing: Boolean;
    FCanvas: IBrush;
    FPainting: IBrush;
    FFrom: TPointF;
    FShapes: TShapes;
    FIndex: Integer;
    FCount: Integer;
    FCache: IBitmap;
    procedure DrawTo(var P: TPointF);
  public
    constructor Create; override;
    procedure GetInfo(out Name: string; out Description: string); override;
    procedure Draw(Params: TAnimateParams); override;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); override;
  end;

constructor TAnimatePaint.Create;
var
  B: IBitmap;
begin
  inherited Create;
  FShapes.Length := 10000;
  B := NewBitmap;
  B.LoadFromFile('images/canvas.jpg');
  FCanvas := NewBrush(B);
  B := NewBitmap;
  B.LoadFromFile('images/painting.jpg');
  FPainting := NewBrush(B);
  FPainting.Opacity := 50;
end;

procedure TAnimatePaint.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Painting Watercolors';
  Description := 'Painting a watercolor picture with animation';
end;

procedure TAnimatePaint.Draw(Params: TAnimateParams);

  function Max(A, B: Float): Integer;
  begin
    if A < B then Result := Trunc(B) else Result := Trunc(A);
  end;

{.$define bw}

var
  White: IBrush;
  B: IBitmap;
  D: Boolean;
  I: Integer;
begin
  White := NewBrush(clWhite);
  White.Opacity := 50;
  if FCache = nil then
  begin
    FCache := NewBitmap(Trunc(Params.Rect.Width), Trunc(Params.Rect.Height));
    {$ifdef bw}
    FCache.Surface.FillRect(NewBrush(clBlack), Params.Rect);
    {$else}
    FCache.Surface.FillRect(FCanvas, Params.Rect);
    {$endif}
  end
  else if (FCache.Height <> Params.Rect.Height) or
    (FCache.Width <> Params.Rect.Width) then
  begin
    B := NewBitmap(Max(FCache.Width, Params.Rect.Width),
      Max(FCache.Height, Params.Rect.Height));
    {$ifdef bw}
    B.Surface.FillRect(NewBrush(clBlack), Params.Rect);
    {$else}
    B.Surface.FillRect(FCanvas, B.ClientRect);
    {$endif}
    B.Surface.FillRect(NewBrush(FCache), FCache.ClientRect);
    FCache := B;
  end;
  for I := FIndex to FCount - 1 do
  begin
    FShapes.Items[I].Draw(FCache.Surface, Params.Time, D);
    if D then
      FIndex := I + 1
    else
      Break;
  end;
  {$ifdef bw}
  FCache.Surface.Fill(White);
  {$else}
  FCache.Surface.Fill(FPainting);
  {$endif}
  Params.Surface.FillRect(NewBrush(FCache), Params.Rect);
  for I := FIndex to FCount - 1 do
    FShapes.Items[I].Draw(Params.Surface, Params.Time, D);
  {$ifdef bw}
  Params.Surface.Fill(White);
  {$else}
  Params.Surface.Fill(FPainting);
  {$endif}
end;

function MidPoint(A, B: TPointF): TPointF;
begin
 {

 Result.X := (A.X + B.X) / 2;
 Result.Y := (A.Y + B.Y) / 2;

 Result.X := A.X / 2 + B.X / 2;
 Result.Y := A.Y / 2 + B.Y / 2;

 }
 Result.X := (A.X * 0.5 + B.X * 0.5);
 Result.Y := (A.Y * 0.5 + B.Y * 0.5);
end;

function FindPoint(A, B: TPointF; Percent: Float): TPointF;
var
  C: Float;
begin
  C := 1 - Percent;
  // Percent = 0.5, C = 0.5
  Result.X := (A.X * C + B.X * Percent) / 2;
  Result.Y := (A.Y * C + B.Y * Percent) / 2;
end;

procedure TAnimatePaint.DrawTo(var P: TPointF);
var
  T, D, M: Float;
  N: TPointF;
  I: Integer;
begin
  T := TimeQuery;
  D := FFrom.Dist(P) - 0.1;
  if D < 0.5 then
    Exit;
  I := 0;
  while I < D do
  begin
    Inc(I);
    M := I / D;
    N.X := P.X - FFrom.X;
    N.X := N.X * M + FFrom.X;
    N.Y := P.Y - FFrom.Y;
    N.Y := N.Y * M + FFrom.Y;
    if FCount = FShapes.Length then
      FShapes.Length := FShapes.Length + 10000;
    FShapes.Items[FCount].Generate(N, T);
    Inc(FCount);
  end;
end;

procedure TAnimatePaint.Mouse(X, Y: Integer; Kind: TMouseEventKind);
var
  P: TPointF;
begin
  P.X := X;
  P.Y := Y;
  case Kind of
    mkDown: FDrawing := True;
    mkMove: if FDrawing then DrawTo(P);
    mkUp: FDrawing := False;
  end;
  FFrom := P;
end;

initialization
  Rubber := Easings['Rubber'];
  RegisterAnimation(TAnimatePaint);
end.

