unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header,ray_math, ray_application, ray_sprite_engine;

type
{ TPlayerShip }
TPlayerShip = class(TPlayerSprite)
private
FDoAccelerate: Boolean;
FDoDeccelerate: Boolean;
FLife: Single;
public
procedure Move( MoveCount: Double); override;
property DoAccelerate: Boolean read  FDoaccelerate write FDoAccelerate;
property DoDeccelerate: Boolean read  FDoDeccelerate write  FDoDeccelerate;
property Life: Single read FLife write FLife;
end;


type
TGame = class(TRayApplication)
  private
  protected
  public
    SpriteEngine: TSpriteEngine;
    GameTexture: TGameTexture;
    Camera2D: TCamera2D;
    Player:TPlayerShip;
    star:TSprite;
    constructor Create; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
  end;

implementation

{ TPlayerShip }

procedure TPlayerShip.Move(MoveCount: Double);
begin
    if IsKeyDown(KEY_LEFT) then
  begin
    Angle:=Angle-1;// Speed/4;
  end;
    if IsKeyDown(KEY_RIGHT) then
  begin
    Angle:=Angle+1;// Speed/4;
  end;

   if IsKeyDown(KEY_UP) then
    begin
      Speed:=Speed+Acceleration;
     Accelerate;
    end
   else
     begin
    Speed:=Speed-Decceleration;
    Deccelerate;
    end;

   DoAnimate:=true;
     UpdatePos;

end;


constructor TGame.Create;
var i:integer;
begin
  //setup and initialization engine
  InitWindow(800, 600, 'raylib [Game Project]'); // Initialize window and OpenGL context 
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT); // Set window configuration state using flags
  SetTargetFPS(120); // Set target FPS (maximum)
  ClearBackgroundColor:= BLACK; // Set background color (framebuffer clear color)
  // Greate the sprite engine and texture image list 
  SpriteEngine:=TSpriteEngine.Create;
  SpriteEngine.RenderOnlyRectangle:=true;

  GameTexture:= TGameTexture.Create;
  GameTexture.LoadFromFile('data/gfx/louse.png');
  GameTexture.LoadFromFile('data/gfx/star.png');

  for i:=0 to 20 do
  begin
  Star:=TSprite.Create(SpriteEngine,GameTexture);
  Star.TextureIndex:=1;
  Star.X:=GetRandomValue(-500,500);
  Star.Y:=GetRandomValue(-500,500);
  Star.Angle:=GetRandomValue(0,360);
  Star.TextureFilter:=tfBilinear;
  end;

  Player:=TPlayerShip.Create(SpriteEngine,GameTexture);
  Player.SetPattern(59,50);
  Player.TextureIndex:=0;
  Player.TextureFilter:=tfBilinear;

  Player.AngleVectorX:=Player.PatternWidth/2;
  Player.AngleVectorY:=Player.PatternHeight/2;
  Player.MaxSpeed:=5;
  Player.MinSpeed:=0;
  Player.Acceleration:= 0.002;
  Player.Decceleration:=0.002;
  Player.Speed:=0;
  Player.Z:=300000;

  Camera2D.zoom:=1;
  Camera2D.target.x:=Player.x;
  Camera2D.target.y:=Player.y;
  Camera2D.offset.x:=800/2;
  Camera2D.offset.y:=600/2;

end;

procedure TGame.Update;
var screenV:TVector2;
begin
    UpdateCamera(@Camera2D);
    SpriteEngine.ClearDeadSprites;  // cleaning dead sprites
    SpriteEngine.Move(GetFrameTime); // move all sprites in SpriteEngine

    Camera2D.target.x:=Player.x;
    Camera2D.target.y:=Player.y;
    SpriteEngine.WX:=Camera2D.target.x-32;
    SpriteEngine.WY:=Camera2D.target.y-32;
    SpriteEngine.Camera:=Camera2d;


    Vector2Set(@screenV,GetScreenWidth/2,GetScreenHeight/2);

    RectangleSet(@SpriteEngine.RenderRectangle,
    Camera2D.target.x-Vector2Scale(screenV, 1.0/Camera2D.zoom).x,
    Camera2D.target.y-Vector2Scale(screenV, 1.0/Camera2D.zoom).y,
    Vector2Scale(screenV, 1.0/Camera2D.zoom).x*2,
    Vector2Scale(screenV, 1.0/Camera2D.zoom).y*2);
end;

procedure TGame.Render;
begin
  BeginMode2D(Camera2D);
  SpriteEngine.Draw;
  EndMode2D;
  DrawFPS(10, 10); // Draw current FPS
end;

procedure TGame.Resized;
begin

end;

procedure TGame.Shutdown;
begin
  SpriteEngine.Free;
  GameTexture.Free;
end;

end.

