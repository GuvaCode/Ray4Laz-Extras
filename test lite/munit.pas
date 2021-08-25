unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, lite_sprite_engine, lite_math_2d;

type

{ TSimple }

TSimple = Class(TSprite)
  public
  procedure Move(MoveCount: Double); override;
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
 TowardToAngle(Player.Angle,1,true);
end;

constructor TGame.Create;
var i:integer;
begin
  Init;
  InitWindow(800, 600, 'raylib [core] - basic window');
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT);
  ClearBgColor:=Black;
  SetTargetFPS(120);
  //FClearBgColor:= WHITE;
//  inherited;





  SpriteEngine:=TSpriteEngine.Create;
  Texture:= TLiteTexture.Create;
  Texture.LoadFromFile('flea.png',61,72);
  Texture.LoadFromFile('PlayerShip.png',64,64);
  Texture.LoadFromFile('louse1.png',64,64);



  //SpriteEngine.Camera:=Camera;
  ///-----///



  Player:=TSprite.Create(SpriteEngine,Texture);
  Player.X:=0;
  Player.Y:=0;
  Player.MirrorMode:=MrmNormal;
//  Player.Scale:=3;
  Player.AngleVectorX:=59/2.0;//*Player.Scale;
  Player.AngleVectorY:=50/2.0;//*Player.Scale;
  Player.TextureIndex:=0;
  Player.TextureFilter:=tfBilinear;

  ;
  for i:=0 to 100 do
  begin
      Simple1:=TSimple.Create(SpriteEngine,Texture);
  Simple1.X:=Random(-4000);
  Simple1.Y:=Random(-3000);
  Simple1.AngleVectorX:=32;//*Player.Scale;
  Simple1.AngleVectorY:=32;//*Player.Scale;
  Simple1.TextureIndex:=2;
  Simple1.TextureFilter:=tfBilinear;
  Simple1.Scale:=2.0;
  end;







  camera.target := Vector2Create( player.x , player.y );
  camera.offset := Vector2Create(800/2.0,600/2.0) ;
  camera.rotation := 0.0;
  camera.zoom := 1.0;


end;

procedure TGame.Init;
begin
end;

procedure TGame.Update;
var WV:TVector2;
begin
  Player.LookAt(GetMouseX + Camera.target.x - Camera.offset.x ,
                GetMouseY + Camera.target.y - Camera.offset.y);

  {WV:=GetScreenToWorld2D(Vector2Create(Player.X,Player.Y),Camera);
  SpriteEngine.WorldX:=Wv.x;
  SpriteEngine.WorldY:=Wv.Y;}
 // Player.Angle:=Player.Angle+1;
  SpriteEngine.Move(GetFrameTime);
end;

procedure TGame.Render;
var testV:Tvector2;
begin
  BeginMode2D(Camera);
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

