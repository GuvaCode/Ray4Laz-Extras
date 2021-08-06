unit mUnit;

{$mode objfpc}{$H+} 
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
interface

uses
  cmem, ray_header, ray_application, ray_sprite_engine, fgl;

type

{ TGame }

TGame = class(TRayApplication)
  private
    SpriteEngine: TSpriteEngine;
    AnimSprite: TAnimatedSprite;
    Paluba: TSprite;
    Bg: TSprite;
    Collision: boolean;
  protected
  public
    procedure LoadingTexture(FileName: string);
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
  end;

var ImagesList: specialize TFPGMap<string, TTexture>; //For image

implementation
uses SysUtils; // for load image

procedure TGame.LoadingTexture(FileName: string);
var  Texture:TTexture;
begin
  Texture:=LoadTexture(Pchar(FileName));
  ImagesList.Add(ChangeFileExt(ExtractFileName(FileName), ''), Texture);
end;

constructor TGame.Create;
begin
  inherited;
  Collision:=false;
  SetTargetFPS(60); // set FPS

  // Set Icon and caption;
  SetWindowIcon(LoadImage('data/gfx/other/akulaico.png'));
  SetWindowTitle('RayLib SpriteEngine for Lazarus');

  //Greate FPGMap for image list
  ImagesList:= specialize TFPGMap<string, TTexture>.Create;

  //Loading image strip
  LoadingTexture('data/gfx/other/akula.png');
  LoadingTexture('data/gfx/other/paluba.png');
  LoadingTexture('data/gfx/other/paluba_bg.png');

  //Create sprite engine
  SpriteEngine := TSpriteEngine.Create(nil);

  SpriteEngine.VisibleWidth := 900000;
  SpriteEngine.VisibleHeight := 900000;

 // Create and setting Annimation sprite
  AnimSprite:=TAnimatedSprite.Create(SpriteEngine);
  with AnimSprite do
  begin
    ImageLib := ImagesList;
    ImageName := 'akula';
    SetPattern(402, 365);
    SetAnim(ImageName, 0, PatternCount-2, 20, True, True , MirrorX);
    //centralize to window
    X:=800/2-AnimSprite.PatternWidth/2;
    Y:=162;
    Z:=200;
  end;



  Bg:= TSprite.Create(SpriteEngine);
  with bg do
  begin
   ImageLib := ImagesList;
   ImageName := 'paluba_bg';
   Width:=6144;
   Height:=768;
   X:=0;
   Y:=0;
   Z:=2;
  end;

  // Create Paluba
  Paluba:=TSprite.Create(SpriteEngine);
  with Paluba do
  begin
   ImageLib := ImagesList;
   ImageName := 'paluba';
   Width:=6144;
   X:=0;
   Y:=296;
   Z:=100;
  end;
end;

procedure TGame.Init;
begin
end;

procedure TGame.Update;
begin
  if IsKeyPressed(KEY_LEFT)  then AnimSprite.MirrorMode:=MirrorNormal;
  if IsKeyPressed(KEY_RIGHT) then AnimSprite.MirrorMode:=MirrorX;
  if IsKeyPressed(KEY_SPACE) then if not AnimSprite.DoAnimate then
  AnimSprite.DoAnimate:=true  else  AnimSprite.DoAnimate:=false;

  if IsKeyPressed(KEY_ONE) then  AnimSprite.AnimPlayMode:=pmForward;
  if IsKeyPressed(KEY_TWO) then  AnimSprite.AnimPlayMode:=pmBackward;

  Collision:= CheckCollisionPointRec(GetMousePosition,RectangleCreate(10,580,160,10));

  if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) and (Collision)
  then OpenURL('https://retrostylegames.com/art-portfolio/freebies/');

   SpriteEngine.WorldX:=AnimSprite.X - 200;
  if  AnimSprite.DoAnimate then
  if AnimSprite.MirrorMode = MirrorNormal then
  begin
   case AnimSprite.AnimPlayMode of
    pmForward : AnimSprite.X:=AnimSprite.X-4;
    pmBackward : AnimSprite.X:=AnimSprite.X+4;
   end;
  end;
   if  AnimSprite.DoAnimate then
   if AnimSprite.MirrorMode = MirrorX then
  begin
   case AnimSprite.AnimPlayMode of
    pmForward : AnimSprite.X:=AnimSprite.X+4;
    pmBackward : AnimSprite.X:=AnimSprite.X-4;
   end;
  end;

  if AnimSprite.X <=200 then AnimSprite.MirrorMode:=MirrorX;
  if AnimSprite.X >=5400 then AnimSprite.MirrorMode:=MirrorNormal;

  SpriteEngine.Move(GetFrameTime); // update sprite engine on frame time
 end;



procedure TGame.Render;
begin
  SpriteEngine.Draw;

  DrawText(PChar(IntToStr(GetFPS)+' FPS'),10,10,10,BLACK);
  DrawText('Press left or right to change sprite mirror',10,26,10,BLACK);
  DrawText('Press space to play or stop annimation',10,38,10,BLACK);
  DrawText('Press 1 or 2 to  change play annimation',10,50,10,BLACK);
  case AnimSprite.AnimPlayMode of
   pmForward: DrawText('Animmation mode Forward',10,62,10,BLACK);
   pmBackward:DrawText('Animmation mode Backward',10,62,10,BLACK);
   pmPingPong:DrawText('Animmation mode PingPong',10,62,10,BLACK);
  end;
  if Collision then DrawRectangle(10,590,157,1,BLACK);
  DrawText('Graphics by RetroStyle Games',10,580,10,BLACK);

end;

procedure TGame.Shutdown;
var i:integer;
begin
  for i:=0 to ImagesList.Count-1 do UnloadTexture(ImagesList.Data[i]); // unload all texture
  ImagesList.Free;
  SpriteEngine.Free;
end;

end.

