unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, ray_sprite_engine, sysutils;

type
{ TFigur }
TFigur = class(TAnimatedSprite)
private
  public
    constructor Create(Engine: TSpriteEngine; Texture: TGameTexture); override;
    procedure Move(MoveCount: Double); override;
    procedure SetLine;
end;


TGame = class(TRayApplication)
  private
  protected
  public
    SpriteEngine: TSpriteEngine;
    GameTexture: TGameTexture;
    Camera2D: TCamera2D;
    Figur:TFigur;
    constructor Create; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
  end;

implementation

{ TFigur }

constructor TFigur.Create(Engine: TSpriteEngine; Texture: TGameTexture);
begin
  inherited Create(Engine, Texture);
  X := 0;
  Y := 0;
  SpeedX := -40;
end;

procedure TFigur.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
  X:=X + SpeedX*MoveCount;

    if ((X > GetScreenWidth) and (SpeedX > 0)) or
      ((X < -96) and (SpeedX < 0)) then
  begin
   SetLine;
  end;
end;

procedure TFigur.SetLine;
begin
  SpeedX :=-SpeedX;
  if SpeedX > 0 then
  begin
    SetAnim(0,7,AnimSpeed,True);
    X := -96;
  end
  else
  begin
    SetAnim(8,15,AnimSpeed,True);
    X := GetScreenWidth + 96;
  end;
  Y := Random(GetScreenHeight-96);
end;



constructor TGame.Create;
var i:integer;
begin
  //setup and initialization engine
  InitWindow(800, 600, 'Sprite Engine Animation Sprite'); // Initialize window and OpenGL context
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT); // Set window configuration state using flags
  SetTargetFPS(60); // Set target FPS (maximum)
  ClearBackgroundColor:= RAYWHITE; // Set background color (framebuffer clear color)
  // Greate the sprite engine and texture image list 
  SpriteEngine:=TSpriteEngine.Create;
  GameTexture:= TGameTexture.Create;
  GameTexture.LoadFromFile('data/gfx/boy.png');

  Camera2d.zoom:=1;

 for i := 0 to 5 do
  begin
   with TFigur.Create(SpriteEngine,GameTexture) do
    begin
      X := 0;
      Y := 0;
      SpeedX  := -(random(100)+50);
      TextureName:='boy';
      AnimSpeed:=10;
      SetPattern(96,96);
      DoAnimate:=true;
      TextureFilter:=tfBilinear;
      SetLine;
    end;
  end;
end;

procedure TGame.Update;
begin
  SpriteEngine.ClearDeadSprites;
  SpriteEngine.Move(GetFrameTime); // move all sprites in SpriteEngine
end;

procedure TGame.Render;
begin
  BeginMode2D(Camera2D);
  SpriteEngine.Draw;

  EndMode2D;

  //DrawRectangle(0,0,800,600,RED);

  DrawFPS(10, 10); // Draw current FPS
end;

procedure TGame.Resized;
begin
  SpriteEngine.VisibleWidth:=GetScreenWidth;
  SpriteEngine.VisibleHeight:=GetScreenHeight;
end;

procedure TGame.Shutdown;
begin
  SpriteEngine.Free;
  GameTexture.Free;
end;

end.

