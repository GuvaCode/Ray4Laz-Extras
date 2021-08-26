unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, ray_sprite_engine;

type

{ TPlayer }

TPlayer = class(TSprite)
  public
  procedure Move(MoveCount: Double); override;
end;

{ TWall }
TWall = class(TSprite)
  public
  procedure Move(MoveCount: Double); override;
  procedure DoCollision(const Sprite: TSprite); Override;
  end;

TGame = class(TRayApplication)
  private
  protected
  public
    Wall: TWall;
    PLayer: TPlayer;
    SpriteEngine: TSpriteEngine;
    GameTexture: TGameTexture;
    constructor Create; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
  end;

implementation

{ TPlayer }

procedure TPlayer.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
  case self.CollideMode of
  cmRect: RectangleSet(@CollideRect,X,Y,128,128);
  cmCircle:
    begin
    Self.CollideRadius:=64;
    Vector2Set(@Self.CollideCenter,X+64,Y+64);
    end;
  cmCircleRec:
    begin
      Self.CollideRadius:=64;
      Vector2Set(@Self.CollideCenter,X+64,Y+64);
      RectangleSet(@CollideRect,X,Y,128,128);
    end;
  end;
end;

{ TWall }

procedure TWall.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
  case self.CollideMode of
  cmRect: RectangleSet(@CollideRect,X,Y,128,128);
  cmCircle:
    begin
    Self.CollideRadius:=64;
    Vector2Set(@Self.CollideCenter,X+64,Y+64);
    end;
  cmCircleRec:
    begin
      Self.CollideRadius:=64;
      Vector2Set(@Self.CollideCenter,X+64,Y+64);
      RectangleSet(@CollideRect,X,Y,128,128);
    end;
  end;
  Collision;
end;


procedure TWall.DoCollision(const Sprite: TSprite);
begin
  inherited DoCollision(Sprite);
  if (Sprite is TPlayer) then
  begin
   Drawtext('On Collision',10,30,20,RED);

  end;
end;

constructor TGame.Create;
begin
  //setup and initialization engine
  InitWindow(800, 600, 'raylib [Game Project]'); // Initialize window and OpenGL context 
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT); // Set window configuration state using flags
  SetTargetFPS(60); // Set target FPS (maximum)
  ClearBackgroundColor:= BLACK; // Set background color (framebuffer clear color)
  // Greate the sprite engine and texture image list 
  SpriteEngine:=TSpriteEngine.Create;
  GameTexture:= TGameTexture.Create;

  GameTexture.LoadFromFile('data/gfx/texture.png',128,128);
  GameTexture.LoadFromFile('data/gfx/texture2.png',128,128);


  Player:=TPlayer.Create(SpriteEngine,GameTexture);
  Player.X:=400;
  Player.Y:=100;
  Player.TextureName:='texture';
  Player.Collisioned:=true;
  Player.CollideMode:=cmRect;
  Player.TextureFilter:=tfBilinear;

  Wall:=TWall.Create(SpriteEngine,GameTexture);
  Wall.X:=100;
  Wall.Y:=100;
  Wall.TextureIndex:=1;
  wall.Collisioned:=true;
  wall.CollideMode:=cmRect;
end;

procedure TGame.Update;
begin
  SpriteEngine.Move(GetFrameTime); // move all sprites in SpriteEngine

   if IsKeyDown(KEY_ONE) then begin
    Player.CollideMode:=cmRect;
    Wall.CollideMode:=cmRect;
   end;

   if IsKeyDown(KEY_TWO) then begin
    Player.CollideMode:=cmCircle;
    Wall.CollideMode:=cmCircle;
   end;

     if IsKeyDown(KEY_THREE) then begin
    Player.CollideMode:=cmCircleRec;
    Wall.CollideMode:=cmCircleRec;
   end;


   if IsKeyDown(KEY_LEFT) then Player.x:=Player.X - 1.0;
   if IsKeyDown(KEY_RIGHT) then Player.x:=Player.X + 1.0;
   if IsKeyDown(KEY_UP) then Player.y:=Player.y - 1.0;
   if IsKeyDown(KEY_Down) then Player.y:=Player.y + 1.0;

  // RectangleSet(@Player.CollideRect,Player.X,Player.Y,128,128);

  // player.Collision;
end;

procedure TGame.Render;
begin
  BeginMode2D(SpriteEngine.Camera);
  SpriteEngine.Draw;


  case Player.CollideMode of
  cmRect:DrawRectangleLines(Round(Player.X),Round(Player.Y),128,128,GOLD);
  cmCircle:DrawCircleLines(Round(Player.CollideCenter.x),Round(Player.CollideCenter.y),Player.CollideRadius,GOLD);
  cmCircleRec:DrawRectangleLines(Round(Player.X),Round(Player.Y),128,128,GOLD);
  end;

  case Wall.CollideMode of
  cmRect: DrawRectangleLines(Round(Wall.X),Round(Wall.Y),128,128,LIME);
  cmCircle: DrawCircleLines(Round(Wall.CollideCenter.x),Round(Wall.CollideCenter.y),wall.CollideRadius,Lime);
  cmCircleRec: DrawCircleLines(Round(Wall.CollideCenter.x),Round(Wall.CollideCenter.y),wall.CollideRadius,Lime);
  end;

  EndMode2D;
  DrawFPS(10, 10); // Draw current FPS
  Drawtext('Press 1 or 3 to change collision mode. Cursor key for moves.',100,10,20,ColorCreate(192,220,192,255));
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

