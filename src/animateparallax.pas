unit AnimateParallax;

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

{ TAnimateParallax }

type
  TAnimateParallax = class(TAnimate)
  private
    FGround: IBitmap;
    FTrees: IBitmap;
    FCity: IBitmap;
    FClouds: IBitmap;

    FGroundBrush: IBrush;
    FTreesBrush: IBrush;
    FCityBrush: IBrush;
    FCloudsBrush: IBrush;
    procedure LoadImages(Height: Integer);
  public
    constructor Create; override;
    procedure GetInfo(out Name: string; out Description: string); override;
    procedure Draw(Params: TAnimateParams); override;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); override;
  end;

constructor TAnimateParallax.Create;
begin
  inherited Create;
  FGround := NewBitmap;
  FTrees := NewBitmap;
  FCity := NewBitmap;
  FClouds := NewBitmap;
end;

var
  Counter: Integer;

procedure TAnimateParallax.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Parallax Demo';
  Description := 'A demonstration of Parallax Animation';
end;

procedure TAnimateParallax.LoadImages(Height: Integer);
var
  Changed: Boolean;
  Scale: Float;
begin
  Changed := Height <> FGround.Height;
  if not Changed then
    Exit;
  // We need to resize our images
  FGround.LoadFromFile('images/parallax/layer_01.png');
  Scale := FGround.Height / Height;
  FGround := FGround.Resample(Round(FGround.Width / Scale), Height);
  FTrees.LoadFromFile('images/parallax/layer_02.png');
  FTrees := FTrees.Resample(Round(FTrees.Width / Scale), Height);
  FCity.LoadFromFile('images/parallax/layer_03.png');
  FCity := FCity.Resample(Round(FCity.Width / Scale), Height);
  FClouds.LoadFromFile('images/parallax/layer_07.png');
  FClouds := FClouds.Resample(Round(FClouds.Width / Scale), Height);
  // Creating our brushes
  FGroundBrush := NewBrush(FGround);
  FTreesBrush := NewBrush(FTrees);
  FCityBrush := NewBrush(FCity);
  FCloudsBrush := NewBrush(FClouds);
  Counter := Counter + 1;
end;

procedure TAnimateParallax.Draw(Params: TAnimateParams);
var
  G: IGradientBrush;
begin
  // Drawing our blue sky
  G := NewBrush(0, 0, 0, Params.Rect.Bottom);
  G.AddStop(clSteelBlue, 0);
  G.AddStop(clSkyBlue, 1);
  Params.Surface.FillRect(G, Params.Rect);
  // Resize our images to fit our window
  LoadImages(Round(Params.Rect.Height));
  // Drawing our bitmaps
  FCloudsBrush.Matrix.Identity;
  FCloudsBrush.Matrix.Translate(Params.Time * 10, 0);
  Params.Surface.FillRect(FCloudsBrush, Params.Rect);
  FCityBrush.Matrix.Identity;
  FCityBrush.Matrix.Translate(Params.Time * 50, 0);
  Params.Surface.FillRect(FCityBrush, Params.Rect);
  FTreesBrush.Matrix.Identity;
  FTreesBrush.Matrix.Translate(Params.Time * 200, 0);
  Params.Surface.FillRect(FTreesBrush, Params.Rect);
  FGroundBrush.Matrix.Identity;
  FGroundBrush.Matrix.Translate(Params.Time * 200, 0);
  Params.Surface.FillRect(FGroundBrush, Params.Rect);
end;

procedure TAnimateParallax.Mouse(X, Y: Integer; Kind: TMouseEventKind);
begin
end;

initialization
  RegisterAnimation(TAnimateParallax);
end.

