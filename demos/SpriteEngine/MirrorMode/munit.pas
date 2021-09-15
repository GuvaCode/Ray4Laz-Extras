unit mUnit;
   //test of 200000 sprites
   // draw only rect render;
{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header,ray_math, ray_application, ray_sprite_engine;

type

{ Tux }

TTux = class(TAnimatedSprite)
  public
   procedure Move(MoveCount: Double); override;
end;

TGame = class(TRayApplication)
  private
  protected
    Icon:TImage;
  public
    Tux:TTux;
    Tux2:TAnimatedSprite;
    SpriteEngine: TSpriteEngine;
    GameTexture: TGameTexture;
    Camera2D:TCamera2D;
    constructor Create; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
  end;


implementation

{ Tux }

procedure TTux.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
  if not DoAnimate then AnimPos:=0;
  LookAt(GetMouseX,GetMouseY);
  //MoveTowards(GetMousePosition,0.5);
end;

constructor TGame.Create;
var i:integer;
begin
  //setup and initialization engine
  InitWindow(800, 600, 'raylib [Game Project]'); // Initialize window and OpenGL context 
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT); // Set window configuration state using flags

  SetTargetFPS(60); // Set target FPS (maximum)
  ClearBackgroundColor:= BLACK; // Set background color (framebuffer clear color)
  // Greate the sprite engine and texture image list 
  SpriteEngine:=TSpriteEngine.Create;
  SpriteEngine.RenderOnlyRectangle:=True;
  GameTexture:= TGameTexture.Create;

  Icon:=LoadImage('data/raylogo.png'); // Load window icon
  SetWindowIcon(Icon);

  GameTexture.LoadFromFile('data/gfx/tux_walking.png');

  for i:=0 to 200000 do
  begin
  Tux2:=TAnimatedSprite.Create(SpriteEngine,GameTexture);
  Tux2.X:=GetRandomValue(-5000,0);
  Tux2.Y:=GetRandomValue(-600,600);
  Tux2.SetPattern(64,64);
  Tux2.AngleVectorX:=64/2;
  Tux2.AngleVectorY:=64/2;
  Tux2.SpeedX:=0.0020;
  Tux2.TextureFilter:=tfBilinear;
  Tux2.SetAnim(0,8,20,True);
  Tux2.DoAnimate:=true;
 end;

  Tux:=TTux.Create(SpriteEngine,GameTexture);
  Tux.X:=800/2.0 - 64/2;
  Tux.Y:=600/2.0 - 64/2;
  Tux.SetPattern(64,64);
  Tux.AngleVectorX:=64/2;
  Tux.AngleVectorY:=64/2;
  Tux.SpeedX:=0.0020;
  Tux.TextureFilter:=tfBilinear;
  Tux.SetAnim(0,8,20,True);



  Camera2D.zoom:=1.5;
  Camera2D.target.x:=Tux.x;
  Camera2D.target.y:=Tux.y;
  Camera2D.offset.x:=800/2;
  Camera2D.offset.y:=600/2;

end;

procedure TGame.Update;
var screenV:TVector2;
begin
  SpriteEngine.Move(GetFrameTime); // move all sprites in SpriteEngine
  if IsKeyDown(KEY_LEFT) then
  begin
    Tux.MirrorMode:=MmX;
    Tux.SetAnim(0,8,20,True);
    Tux.X:=Tux.X-4;
  end;
    if IsKeyDown(KEY_RIGHT) then
  begin
    Tux.MirrorMode:=MmNormal;
    Tux.SetAnim(0,8,20,True);
    Tux.X:=Tux.X+4;
  end;



    Tux.DoAnimate:=true;

{   if IsKeyDown(KEY_SPACE) then
    begin
     if Tux.DoAnimate then Tux.DoAnimate:=false else Tux.DoAnimate:=true;
    end; }

    Camera2D.target.x:=Tux.x;
    Camera2D.target.y:=Tux.y;


    Vector2Set(@screenV,GetScreenWidth/2,GetScreenHeight/2);

    RectangleSet(@SpriteEngine.RenderRectangle,
    Camera2D.target.x-Vector2Scale(screenV, 1.0/Camera2D.zoom).x,
    Camera2D.target.y-Vector2Scale(screenV, 1.0/Camera2D.zoom).y,
    Vector2Scale(screenV, 1.0/Camera2D.zoom).x*2,
    Vector2Scale(screenV, 1.0/Camera2D.zoom).y*2);
    UpdateCamera(@Camera2D);





end;

procedure TGame.Render;
var screenV:TVector2;
begin
  BeginMode2D(Camera2D);
  SpriteEngine.Draw;
  DrawRectangleLinesEx(SpriteEngine.RenderRectangle,2,GREEN);

  EndMode2D;
  DrawFPS(10, 10); // Draw current FPS
  DrawText('Press Left or Right to shange Mirror mode. Press Space to start or stop animation.',10,30,10,RED);
end;

procedure TGame.Resized;
begin
 // SpriteEngine.VisibleWidth:=GetScreenWidth*3;
 // SpriteEngine.VisibleHeight:=GetScreenHeight*3;
end;

procedure TGame.Shutdown;
begin
  SpriteEngine.Free;
  GameTexture.Free;
end;

end.

