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
    Engine3d:T3DEngine;
    Texture: TGameTexture;
    Ground: array of array of TRaySprite;
    test:TRaySprite;
    plane:T3DModel;
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
  MapSize = 2;
var a,b:integer;
begin
  Engine := T2DEngine.Create;
  camMain.zoom:=1;
  Engine.Camera := CamMain;
  Texture := TGameTexture.Create;
  Texture.LoadFromFile('bg.png', 256, 256);
  Texture.LoadFromFile('1.png', 128, 128);

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
      Ground[a, b].VisibleArea := Rect(-300, -300, 800, 600);
    end;
  end;


    test:=TRaySprite.Create(engine,Texture);
    test.TextureIndex:=1;
    test.X:=300;
    test.Y:=300;
    test.Z:=100;
  //  test.Alpha:=120;
    test.Angle:=20;

    Engine3d:=T3DEngine.Create;
    plane:=T3DModel.Create(Engine3d,'plane.obj','plane_diffuse.png');

  cam.position := Vector3Create(3.0, 3.0, 3.0);
  cam.target := Vector3Create(0.0, 1.5, 0.0);
  cam.up := Vector3Create(0.0, 9.0, 0.0);
  cam.fovy := 7.0;
  cam._type := CAMERA_PERSPECTIVE;
  SetCameraMode(cam, CAMERA_THIRD_PERSON); // Set an orbital camera mode
end;

procedure TGame.Update;
begin
 // Dec(test.Alpha) ;
  test.Angle:=test.Angle+0.1;
  engine.Move(1);
  engine3d.Move(1);
end;

procedure TGame.Render;
begin
  ClearBackground(blue);
 BeginMode2D(camMain);
  engine.Draw;
  EndMode2D();
  /////
  BeginMode3d(cam);
  Engine3d.Draw();
  EndMode3d;

end;

procedure TGame.Shutdown;
begin
end;

end.

