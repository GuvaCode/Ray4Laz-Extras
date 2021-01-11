unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_headers, ray_application, ray_model, math;

type
TGame = class(TRayApplication)
  private
  protected
  public
    Engine3D: T3DEngine;
    Cam: TCamera;
    Test:TModelSprite;
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
begin
    SetConfigFlags(FLAG_MSAA_4X_HINT);
    Engine3D:=T3DEngine.Create;
  Engine3D.Camera:=Cam;

  Test:=TModelSprite.Create(Engine3D,'dwarf.obj');
  Test.X:=0;
  Test.Y:=0;
  Test.Z:=0;

    // Define the camera to look into our 3d world
  cam.position := Vector3Create(3.0, 3.0, 3.0);
  cam.target := Vector3Create(0.0, 1.5, 0.0);
  cam.up := Vector3Create(0.0, 1.0, 0.0);
  cam.fovy := 45.0;
  cam._type := CAMERA_PERSPECTIVE;

  SetCameraMode(Cam, CAMERA_ORBITAL); // Set an orbital camera mode

end;

procedure TGame.Update;
begin
  Engine3D.Move(1);
 // UpdateCamera(@Camera); // Update camera
 UpdateCamera(@cam); // Update camera
end;

procedure TGame.Render;
begin
   ClearBackground(Blue);

    BeginMode3d(cam);

 //   DrawModel(dwarf, position, 2.0, WHITE); // Draw 3d model with texture
  //  DrawGrid(10, 0.5); // Draw a grid

    Engine3d.Draw();

    DrawGrid(10, 0.5); // Draw a grid

    EndMode3d();

end;

procedure TGame.Shutdown;
begin
end;

end.

