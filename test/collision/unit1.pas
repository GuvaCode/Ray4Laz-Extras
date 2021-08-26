unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, ray_sprite_engine, sysutils;

type

{ TSpriteTest }

{ TFigur }

TFigur = class(TAnimatedSprite)
private
  FSpeed: integer;
  public
    procedure Move(MoveCount: Double); override;
    procedure SetLine;
end;


TGame = class(TRayApplication)
  private
  protected
  public
    SpriteEngine: TSpriteEngine;
    GameTexture: TGameTexture;
    Figur:TFigur;
    constructor Create; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
  end;

implementation

{ TFigur }

procedure TFigur.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
   // X :=300;// X + SpeedX*MoveCount;
   // Y:=300;
 // self.DoAnimate:=true;
 // DoAnim(True, 9,15,20);
 // if ((X > 800) and (SpeedX > 0)) or  ((X < -96) and (SpeedX < 0)) then
  //begin

   // SetLine;
  //end;
  writeln(Round(self.AnimPos));
  DrawText(PChar(IntToStr(Round(Self.AnimPos))),100,0,14,ColorCreate(0,0,255,255));
end;

procedure TFigur.SetLine;
begin
   SpeedX := -SpeedX;
  if SpeedX > 0 then
  begin

    //DoAnim(True,0,15,20);
    X := -96;
  end
  else
  begin

    //DoAnim(True, 8,15,20);
    X := 800 + 96;
  end;
  Y := Random(600-96);
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
  GameTexture.LoadFromFile('boy.png',96,96);

  Figur:=TFigur.Create(SpriteEngine,GameTexture);

  Figur.X := 0;
  Figur.Y := 0;
  Figur.SpeedX  :=20;// -(random(100)+50);
  Figur.TextureName:='boy';
  figur.AnimSpeed:=Abs(Figur.SpeedX / 7.5);
  Figur.SetPattern(96,96);
  Figur.DoAnimate:=true;
 // figur.DoAnim(True, 8,15,figur.AnimSpeed);
  Figur.SetAnim(8,15,20,True);
//  Figur.BlendingEffect:=beMultiplied;
  Figur.TextureFilter:=tfPoint;
 // SpriteEngine.CameraZoom:=1;


end;

procedure TGame.Update;
begin
  SpriteEngine.ClearDeadSprites;
  SpriteEngine.Move(GetFrameTime); // move all sprites in SpriteEngine
end;

procedure TGame.Render;
begin
  BeginMode2D(SpriteEngine.Camera);
  SpriteEngine.Draw;
  EndMode2D;
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

