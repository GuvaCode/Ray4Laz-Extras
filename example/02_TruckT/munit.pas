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
      Engine3d: TModelEngine;
      Cube:   TMesh;
      skybox: TModel;
      Truck:  T3dModel;
      Truck1: T3dModel;

    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure CreateSkyBox;
    procedure RenderSkyBox;
    procedure CreateLightss;
end;

const ShadersPath ='data/shaders/';
      GfxPath     ='data/gfx/';
      ModelPath   ='data/model/';

var animsCount: integer;
    animFrameCounter: integer;
    animationDirection:integer;
implementation

constructor TGame.Create;
begin
  inherited;
      SetConfigFlags(FLAG_MSAA_4X_HINT);      // Enable Multi Sampling Anti Aliasing 4x (if available)
  SetTargetFPS(60);
  Engine3d:=TModelEngine.Create;
//  CreateSkyBox;


  Truck:=T3DModel.Create(Engine3d);

  Truck.Load3dModel('data/model/sea.glb');

 // Truck.Load3dModelAnimations('data/model/sea.glb',&animsCount);



  {Truck1:=T3DModel.Create(Engine3d);
  Truck1.Load3dModel('data/model/truck_01.glb');}
  //Truck1.Scale:=0.1;

  Engine3d.EngineCameraMode:=cmThirdPerson;
  Engine3D.DrawsGrid:=TRUE;



end;

procedure TGame.Init;
begin

end;

procedure TGame.Update;
begin
         if IsKeyDown(KEY_SPACE) then
        begin
          {  animFrameCounter += animationDirection;

            if (animFrameCounter >= anims[0].frameCount) or (animFrameCounter <= 0) then
            begin
                animationDirection *= -1;
                animFrameCounter += animationDirection;
            end;


            UpdateModelAnimation(model, anims[0], animFrameCounter); }
        end;

 {if (animFrameCounter <= Truck.Anims[0].frameCount) then
 animFrameCounter:=animFrameCounter+1 else animFrameCounter:=0;
  Truck.Update3dModelAnimations(animFrameCounter);
}


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
//    UnloadShader(skybox.materials[0].shader);
 //   UnloadTexture(skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture);
 //      UnloadModel(skybox);        // Unload skybox model
end;

procedure TGame.CreateSkyBox;
var img: TImage;
    mMap:Integer;
begin
   Cube:=GenMeshCube(1.0,1.0,1.0);
   SkyBox:=LoadModelFromMesh(cube);
   Skybox.materials[0].shader := LoadShader(ShadersPath+'skybox.vs',ShadersPath+'skybox.fs');
   mMap:=MATERIAL_MAP_CUBEMAP;
   SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, 'environmentMap'), @mMap , SHADER_UNIFORM_INT);
   img := LoadImage(GfxPath+'skybox/spacebox.png');
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

procedure TGame.CreateLightss;
begin

end;

end.

