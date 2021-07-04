unit mUnit;

{$mode objfpc}{$H+}{$M+} 

interface

uses
  cmem, ray_header, ray_application, ray_model, ray_rlgl;

type

{ TGame }

TGame = class(TRayApplication)
  private
  protected
  public
      Engine3d: T3DEngine;
      Cube:   TMesh;
      skybox: TModel;
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure CreateSkyBox;
    procedure RenderSkyBox;
end;

implementation

constructor TGame.Create;
begin
  inherited;
  SetTargetFPS(60);
  Engine3d:=T3DEngine.Create;
  CreateSkyBox;
end;

procedure TGame.Init;
begin

end;

procedure TGame.Update;
begin
  Engine3d.Move(GetFrameTime);
end;

procedure TGame.Render;
begin
  RenderSkyBox;
  Engine3d.Draw;
end;

procedure TGame.Shutdown;
begin
   // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(skybox.materials[0].shader);
    UnloadTexture(skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture);
    UnloadModel(skybox);        // Unload skybox model
end;

procedure TGame.CreateSkyBox;
var img: TImage;
    mMap:Integer;
begin
   // Load skybox model
   Cube:=GenMeshCube(1.0,1.0,1.0);
   SkyBox:=LoadModelFromMesh(cube);
   Skybox.materials[0].shader := LoadShader('data/shaders/skybox.vs','data/shaders/skybox.fs');
   mMap:=MATERIAL_MAP_CUBEMAP;
   SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, 'environmentMap'), @mMap , SHADER_UNIFORM_INT);
   img := LoadImage('data/gfx/skybox/spacebox.png');
   skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture := LoadTextureCubemap(img, CUBEMAP_LAYOUT_AUTO_DETECT);
   UnloadImage(img);
end;

procedure TGame.RenderSkyBox;
begin
  BeginMode3D(Engine3d.camera);
   rlDisableBackfaceCulling();
   rlDisableDepthMask();
   DrawModel(skybox, Vector3Create(0, 0, 0), 1.0, white);
   rlEnableBackfaceCulling();
   rlEnableDepthMask();
  EndMode3D();
end;

end.

