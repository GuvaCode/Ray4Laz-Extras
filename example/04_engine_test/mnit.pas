unit mnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, math, ray_sprites;



type
TGame = class(TRayApplication)
  private
  protected
  public
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
  end;

const
  GfxPath     ='data/gfx/';

  Var Engine:TSpriteEngine;
      GameTexture:TGameTexture;
      Player:TRayAnimatedSprite;
      TestMiku:TRaySprite;
implementation


constructor TGame.Create;
begin
  inherited;
   Engine:=TSpriteEngine.Create;
   GameTexture:=TGameTexture.Create;
   GameTexture.LoadFromFile(GfxPath+'miku.png',128,128);
   Player := TRayAnimatedSprite.Create(Engine, GameTexture);
   Player.TextureIndex:=0;
   Player.X := 380;
   Player.Y := 250;
   Player.Z := 100;
   Player.FlipState:=fsNormal;
   Player.Scale:=1;
   PLayer.Angle:=0;
   Player.Collisioned:=true;
   TestMiku:=TRaySprite.Create(Engine,GameTexture);
   TestMiku.Collisioned:=true;
   TestMiku.X:=120;
   TestMiku.Y:=250;
   TestMiku.Collisioned:=true;
   TestMiku.TextureIndex:=0;
   TestMiku.Z:=99;
   SetTargetFPS(60);
end;

procedure TGame.Init;
begin

end;

procedure TGame.Update;
begin
   //Player.Collision;
  TestMiku.Collision;
  if IsKeyDown(KEY_RIGHT) then
   begin
     Player.DoAnim(True,0,7,6);
     Player.FlipState:=fsX;
     Player.X:=Player.X+2;
   end else
    if IsKeyDown(KEY_LEFT) then
   begin
     Player.DoAnim(True,0,7,6);
     Player.FlipState:=fsNormal;
     Player.X:=Player.X-2;
   end else


   Player.DoAnim(True,0,0,0);



   Engine.Move(GetFrameTime);

end;

procedure TGame.Render;
begin
  Engine.Draw();
end;

procedure TGame.Shutdown;
begin
 GameTexture.Free;
end;

end.

