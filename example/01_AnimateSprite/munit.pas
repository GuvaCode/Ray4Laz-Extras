unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, ray_sprite_engine, fgl;

type

{ TGame }

TGame = class(TRayApplication)
  private
    SpriteEngine: TSpriteEngine;
    AnimSprite: TAnimatedSprite;
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
   SetTargetFPS(60); // set FPS

  //Greate FPGMap for image list
  ImagesList:= specialize TFPGMap<string, TTexture>.Create;

  //Loading image strip
  LoadingTexture('data/gfx/other/akula.png');

  //Create sprite engine
  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.VisibleWidth := 1800;
  SpriteEngine.VisibleHeight := 1600;

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
    Y:=600/2-PatternHeight/2;
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
  AnimSprite.DoAnimate:=true
  else  AnimSprite.DoAnimate:=false;

  if IsKeyPressed(KEY_ONE) then AnimSprite.AnimPos:=0; AnimSprite.AnimPlayMode:=pmForward;
  if IsKeyPressed(KEY_TWO) then AnimSprite.AnimPos:=0; AnimSprite.AnimPlayMode:=pmBackward;
  if IsKeyPressed(KEY_THREE) then begin AnimSprite.AnimPos:=0; AnimSprite.AnimPlayMode:=pmPingPong;  end;

  SpriteEngine.Move(GetFrameTime); // update sprite engine on frame time

end;

procedure TGame.Render;
begin
  DrawText(PChar(IntToStr(GetFPS)+' FPS'),10,10,10,GREEN);
  DrawText('Press left or right to change sprite mirror',10,26,10,BLUE);
  DrawText('Press space to play or stop annimation',10,38,10,ORANGE);
  DrawText('Press 1 to 3 to  change play annimation',10,50,10,ORANGE);
  case AnimSprite.AnimPlayMode of
   pmForward: DrawText('Animmation mode Forward',10,62,10,BLUE);
   pmBackward:DrawText('Animmation mode Backward',10,62,10,BLUE);
   pmPingPong:DrawText('Animmation mode PingPong',10,62,10,BLUE);
  end;
  SpriteEngine.Draw;
end;

procedure TGame.Shutdown;
var i:integer;
begin
  for i:=0 to ImagesList.Count-1 do UnloadTexture(ImagesList.Data[i]); // unload all texture
  ImagesList.Free;
  SpriteEngine.Free;
end;

end.

