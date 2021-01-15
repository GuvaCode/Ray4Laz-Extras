unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_headers, ray_application, ray_sprites, ray_model, classes;

type
TGame = class(TRayApplication)
  private
  protected
  public
    CamMain: TCamera2D;
    Cam:TCamera3d;
    Engine: T2DEngine;

    Texture: TGameTexture;
    Ground: array of array of TRaySprite;
    test:TRaySprite;
      Player: TRayAnimatedSprite;
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
  end;

implementation

constructor TGame.Create;
begin
  inherited;

end;

procedure TGame.Init;
const
  MapSize = 20;
var a,b:integer;
begin
  Engine := T2DEngine.Create;
  camMain.zoom:=1;
  Engine.Camera := CamMain;
  Texture := TGameTexture.Create;
  Texture.LoadFromFile('bg.png', 256, 256);
  Texture.LoadFromFile('1.png', 128, 128);
  Texture.LoadFromFile('Guest.png', 32, 48);

  SetLength(Ground, MapSize + 1, MapSize + 1);

  for a := 0 to MapSize do
  begin
    for b := 0 to MapSize do
    begin
      Ground[a, b] := TRaySprite.Create(Engine, Texture);
      Ground[a, b].TextureName :='bg.png';
      Ground[a, b].X := a * 256;
      Ground[a, b].Y := b * 256;
      Ground[a, b].Z := 1;
    //  Ground[a, b].VisibleArea := Rect(-300, -300, 800, 600);
    end;
  end;


    test:=TRaySprite.Create(engine,Texture);
    test.TextureIndex:=1;
    test.X:=300;
    test.Y:=300;
    test.Z:=100;
    test.Alpha:=120;
    test.Angle:=20;

  Player := TRayAnimatedSprite.Create(Engine, Texture);
  Player.TextureIndex := 2;

  Player.PatternHeight := 48;
  Player.PatternWidth := 32;

  Player.X := 380;
  Player.Y := 250;
  Player.Z := 999;
  Player.AnimPos := 1;






end;

procedure TGame.Update;
const AnimSpeed = 0.999;
begin
 // Dec(test.Alpha) ;
 // test.Angle:=test.Angle+0.1;
  engine.Move(1);



 /// test.X:=test.X+1;
//  engine.WorldX:=test.X;
 // camMain.target.x:= engine.WorldX
 camMain.target.X := PLayer.X - 400;
 camMain.target.Y := Player.Y - 250;
// player.Split3;
        Player.DoAnim(True, 5, 8, AnimSpeed);
end;

procedure TGame.Render;
begin
  ClearBackground(blue);

 BeginMode2D(camMain);
  engine.Draw;
  EndMode2D();
  /////
 DrawFPS(10,10)

end;

procedure TGame.Shutdown;
begin
end;

end.

