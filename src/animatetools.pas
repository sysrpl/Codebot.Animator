unit AnimateTools;

{$mode delphi}

interface

uses
  Codebot.System,
  Codebot.Graphics,
  Codebot.Graphics.Types,
  Graphics;

{ TAnimate }

type
  TAnimateParams = class
    Surface: ISurface;
    Rect: TRectF;
    Font: IFont;
    Time: Float;
  end;

  TMouseEventKind = (mkDown, mkMove, mkUp);

  TAnimate = class
  public
    constructor Create; virtual;
    procedure GetInfo(out Name: string; out Description: string); virtual;
    procedure Draw(Params: TAnimateParams); virtual; abstract;
    procedure Mouse(X, Y: Integer; Kind: TMouseEventKind); virtual;
  end;

  TAnimateClass = class of TAnimate;
  TAnimationList = TArray<TAnimateClass>;

procedure RegisterAnimation(AnimateClass: TAnimateClass);
procedure RequestAnimations(out List: TAnimationList);

implementation

{ TAnimate }

constructor TAnimate.Create;
begin
end;

procedure TAnimate.GetInfo(out Name: string; out Description: string);
begin
  Name := 'Animation name goes here';
  Description := 'Description of the animation goes here';
end;

procedure TAnimate.Mouse(X, Y: Integer; Kind: TMouseEventKind);
begin
end;

var
  AnimationList: TArrayList<TAnimateClass>;

procedure RegisterAnimation(AnimateClass: TAnimateClass);
begin
  AnimationList.Push(AnimateClass);
end;

procedure RequestAnimations(out List: TAnimationList);
begin
  List := AnimationList;
end;

end.

