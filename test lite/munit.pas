unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, lite_sprite_engine, lite_math_2d;

type

{ TSimple }

TSimple = Class(TAnimatedSprite)
private
  FSpeed: integer;
  public
  procedure Move(MoveCount: Double); override;
  property Speed: integer read FSpeed write FSpeed;
end;


TGame = class(TRayApplication)
  private
  protected
  public
    SpriteEngine:TSpriteEngine;
    Camera:TCamera2d;
    Texture: TLiteTexture;

    Simple1:TSimple;
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
  end;
var Player:TSprite;

implementation
uses SysUtils;

{ TSimple }

procedure TSimple.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
 // LookAt(Player.X,Player.Y);
 TowardToAngle(Player.Angle,Speed * MoveCount ,true);
 Self.DoAnimate:=True;
 DoAnim(true,0,Self.PatternCount,Speed,pmForward);
end;

constructor TGame.Create;
var i:integer;
begin
  InitWindow(800, 600, 'raylib [core] - basic window');
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT);
  ClearBgColor:=Black;
  SetTargetFPS(60);
  //FClearBgColor:= WHITE;
//  inherited;





  SpriteEngine:=TSpriteEngine.Create;




  Texture:= TLiteTexture.Create;
  Texture.LoadFromFile('flea.png',61,72);
  Texture.LoadFromFile('PlayerShip.png',64,64);
  Texture.LoadFromFile('louse1.png',64,64);
  Texture.LoadFromFile('AnimShip1.png',64,64);

  Texture.LoadFromFile('Roids0.png',64,64);
  //SpriteEngine.Camera:=Camera;
  ///-----///



  Player:=TSprite.Create(SpriteEngine,Texture);
  Player.X:=0;
  Player.Y:=0;
  Player.MirrorMode:=MmNormal;
//  Player.Scale:=3;
  Player.AngleVectorX:=59/2.0;//*Player.Scale;
  Player.AngleVectorY:=50/2.0;//*Player.Scale;
  Player.TextureIndex:=0;
  Player.TextureFilter:=tfBilinear;

  ;
  for i:=0 to 10 do
  begin
  Simple1:=TSimple.Create(SpriteEngine,Texture);
  Simple1.X:=GetRandomValue(-600,600);
  Simple1.Y:=GetRandomValue(-600,600);
  Simple1.AngleVectorX:=32;//*Player.Scale;
  Simple1.AngleVectorY:=32;//*Player.Scale;
  Simple1.TextureIndex:=4;
  Simple1.TextureFilter:=tfBilinear;
  Simple1.Speed:=GetRandomValue(30,120);

 { Simple1.PatternWidth:=64;
  Simple1.PatternHeight:=64;}
  Simple1.SetPattern(64,64);
  Simple1.AnimPos:=1;
  Simple1.DoAnimate:=true;


  end;


  SpriteEngine.CameraTarget:=Vector2Create( player.x , player.y );
  SpriteEngine.CameraOffset:=Vector2Create(800/2.0,600/2.0) ;


end;

procedure TGame.Init;
begin
end;

procedure TGame.Update;
//var WV:TVector2;
begin
  Player.LookAt(GetMouseX + SpriteEngine.Camera.target.x - SpriteEngine.Camera.offset.x ,
                GetMouseY + SpriteEngine.Camera.target.y - SpriteEngine.Camera.offset.y);

  Simple1.DoAnim(true,1,8,10);
 // WV:=GetWorldToScreen2D(Vector2Create(Player.X,Player.Y),Camera);
 // SpriteEngine.WorldX:=Player.X;
 // SpriteEngine.WorldY:=Player.Y;
 // Player.Angle:=Player.Angle+1;
 SpriteEngine.ClearDeadSprites;
  SpriteEngine.Move(GetFrameTime);
end;

procedure TGame.Render;
var testV:Tvector2;
var VA:TRectangle;

begin
  testV:=GetWorldToScreen2D(Vector2Create(Player.X,Player.Y),SpriteEngine.Camera);


  BeginMode2D(SpriteEngine.Camera);

  SpriteEngine.Draw;

  EndMode2D;

  DrawText(PChar(FloatTostr(Player.Angle)),10,50,10,RED);
  DrawText(PChar(IntToStr(GetFPS)+' FPS'),10,10,10,RED);


  testV:=GetWorldToScreen2D(GetMousePosition,Camera);
  DrawText(PChar(FloatTostr(testv.y)),10,80,10,RED);



end;

procedure TGame.Shutdown;
begin
end;

end.

