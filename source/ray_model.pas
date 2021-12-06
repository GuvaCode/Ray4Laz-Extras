unit ray_model;

{$mode objfpc}{$H+}
 //is test module
interface

uses
  ray_header, ray_math, ray_rlgl, classes;

type
  TModelDrawMode = (dmNormal, dmEx, dmWires, dmWiresEx);
  TModelEngineCameraMode = (cmCustom, cmFree, cmOrbital, cmFirstPerson, cmThirdPerson);

  { TModelEngine }
  TModelEngine = class
   private
     FCameraPosition: TVector3;
     FCameraPositionX: Single;
     FCameraPositionY: Single;
     FCameraPositionZ: Single;
     FCameraTarget: TVector3;
     FCameraUp: TVector3;
     FEngineCameraMode: TModelEngineCameraMode;
     FGridSlices: longint;
     FGridSpacing: single;
     FShowSkyBox: boolean;
     FWorld: TVector3;
     FCamera: TCamera;
     FDrawsGrid: Boolean;
     FSkyBox: TModel;

     function GetCameraPositionX: Single;
     function GetCameraPositionY: Single;
     function GetCameraPositionZ: Single;
     procedure SetCameraPosition(AValue: TVector3);
     procedure SetCameraPositionX(AValue: Single);
     procedure SetCameraPositionY(AValue: Single);
     procedure SetCameraPositionZ(AValue: Single);
     procedure SetCameraTarget(AValue: TVector3);
     procedure SetCameraUp(AValue: TVector3);
     procedure SetDrawsGrid(AValue: boolean);
     procedure SetEngineCameraMode(AValue: TModelEngineCameraMode);

     procedure SetGridSlices(AValue: longint);
     procedure SetGridSpacing(AValue: single);
     procedure SetShowSkyBox(AValue: boolean);
     procedure SetWorldX(Value: Single);
     procedure SetWorldY(Value: Single);
   protected
     procedure CreateSkyBox;
   public
     List: TList;
     DeadList: TList;

     procedure Draw();
     procedure ClearDeadModel;
     procedure Move(MoveCount: Double);
     procedure LoadSkyBox(FileName :String);

     constructor Create;
     destructor Destroy; override;

     property Camera: TCamera read FCamera write FCamera;


     property WorldX: Single read FWorld.X write SetWorldX;
     property WorldY: Single read FWorld.Y write SetWorldY;

     property DrawsGrid: boolean read FDrawsGrid write SetDrawsGrid;
     property GridSlices:longint read FGridSlices write SetGridSlices;
     property GridSpacing: single read FGridSpacing write SetGridSpacing;

     property EngineCameraMode: TModelEngineCameraMode read FEngineCameraMode write SetEngineCameraMode;

     property CameraPosition: TVector3 read FCameraPosition write SetCameraPosition;
     property CameraPositionX: Single read GetCameraPositionX write SetCameraPositionX;
     property CameraPositionY: Single read GetCameraPositionY write SetCameraPositionY;
     property CameraPositionZ: Single read GetCameraPositionZ write SetCameraPositionZ;

     property CameraTarget: TVector3 read FCameraTarget write SetCameraTarget;
     property CameraUp: TVector3 read FCameraUp write SetCameraUp;


     property ShowSkyBox: boolean read FShowSkyBox write SetShowSkyBox;


  end;

  { T3dModel }
  T3dModel = class
  private
    FAngle: Single;
    FAngleX: Single;
    FAngleY: Single;
    FAngleZ: Single;
    FAnimationIndex: longint;
    FAnimationSpeed: Single;

    FAxis: TVector3;
    FAxisX: Single;
    FAxisY: Single;
    FAxisZ: Single;
    FCollisioned: Boolean;
    FColor: TColor;
    FDrawMode: TModelDrawMode;
    FScale: Single;
    FScaleEx: TVector3;
    FPosition: TVector3;
    FAnims : PModelAnimation;
    FAnimCont: integer;
    FRayCollision: TRayCollision;

    procedure SetAnimationIndex(AValue: longint);
    procedure SetAnimationSpeed(AValue: Single);
    procedure SetScale(AValue: Single);

  protected
    FEngine: TModelEngine;
    FModel: TModel;
    FTexture: TTexture2d;
    FIsModelAnimation: boolean;
    FAnimFrameCounter: Single;
    procedure DoCollision(const CollModel: T3dModel); virtual;
  public
    IsModelDead: Boolean;
    Visible: Boolean;
    procedure Draw();
    procedure Move(MoveCount: Single); virtual;
    procedure Dead();
    procedure Load3dModel(FileName: String);
    procedure Load3dModelTexture(FileName: String);
    procedure Load3dModelAnimations(FileName:String);
    procedure Update3dModelAnimations(MoveCount: Single);

    procedure Collision(const Other: T3dModel); overload; virtual;
    procedure Collision; overload; virtual;

    constructor Create(Engine: TModelEngine); virtual;
    destructor Destroy; override;


    property AxisX: Single read FAxisX write FAxisX;
    property AxisY: Single read FAxisY write FAxisY;
    property AxisZ: Single read FAxisZ write FAxisZ;

    property Angle: Single read FAngle write FAngle;
    property AngleX: Single read FAngleX write FAngleX;
    property AngleY: Single read FAngleY write FAngleY;
    property AngleZ: Single read FAngleZ write FAngleZ;


    property X: Single read FPosition.X write FPosition.X;
    property Y: Single read FPosition.Y write FPosition.Y;
    property Z: Single read FPosition.Z write FPosition.Z;

    property Scale: Single read FScale write SetScale;
    property Color: TColor read FColor write FColor;
    property DrawMode: TModelDrawMode read FDrawMode write FDrawMode;
    property Anims: PModelAnimation read FAnims write FAnims;
    property Model: TModel read FModel write FModel;
    property AnimationIndex: longint read FAnimationIndex write SetAnimationIndex;
    property AnimationSpeed: Single read FAnimationSpeed write SetAnimationSpeed;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
  end;

  const LE = #10;

implementation

{ T3dModel }

procedure T3dModel.SetScale(AValue: Single);
begin
//  if FScale=AValue then Exit;
  FScale:=AValue;
  Vector3Set(@FScaleEx,FScale,FScale,FScale);
end;

procedure T3dModel.DoCollision(const CollModel: T3dModel);
begin
  ///
end;

procedure T3dModel.SetAnimationIndex(AValue: longint);
begin
  if FAnimationIndex=AValue then Exit;
  FAnimationIndex:=AValue;
end;

procedure T3dModel.SetAnimationSpeed(AValue: Single);
begin
  if FAnimationSpeed=AValue then Exit;
  FAnimationSpeed:=AValue;
end;

procedure T3dModel.Draw();
begin
  if Assigned(FEngine) then
    case FDrawMode of
    dmNormal: DrawModel(FModel, FPosition, FScale, WHITE); // Draw 3d model with texture
    dmEx: DrawModelEx(FModel, FPosition, FAxis, FAngle, FScaleEx, FColor); // Draw a model with extended parameters
    dmWires: DrawModelWires(FModel, FPosition, FScale, FColor);  // Draw a model wires (with texture if set)
    dmWiresEX: DrawModelWiresEx(FModel,FPosition,FAxis, FAngle, FScaleEx,FColor);
    end;
end;

procedure T3dModel.Move(MoveCount: Single);
begin
  FModel.transform:=MatrixRotateXYZ(Vector3Create(DEG2RAD*FAxisX,DEG2RAD*FAxisY,DEG2RAD*FAxisZ));

  // DEG2RAD
   Vector3Set(@FAxis,FAxisX,FAxisY,FAxisZ);
end;

procedure T3dModel.Dead();
begin
   if IsModelDead = False then
  begin
    IsModelDead := True;
    FEngine.DeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure T3dModel.Load3dModel(FileName: String);
begin
  FModel:=LoadModel(PChar(FileName));
end;

procedure T3dModel.Load3dModelTexture(FileName: String);
begin
  FTexture:= LoadTexture(PChar(FileName));
  SetMaterialTexture(@FModel.materials[0], MATERIAL_MAP_DIFFUSE, FTexture);//todo
end;

procedure T3dModel.Load3dModelAnimations(FileName: String);
begin
   FModel:=LoadModel(PChar(FileName));
   FAnimCont:=0;
   FAnims:=LoadModelAnimations(PChar(FileName),@FAnimCont);
   FAnimationIndex:=0;
   FIsModelAnimation:=True;
end;

procedure T3dModel.Update3dModelAnimations(MoveCount: Single);
begin
if Self.FIsModelAnimation then
 begin
   FAnimFrameCounter:= FAnimFrameCounter + FAnimationSpeed * MoveCount;
   UpdateModelAnimation(Fmodel, FAnims[FAnimationIndex], Round(FAnimFrameCounter));
   if FAnimFrameCounter >= FAnims[FAnimationIndex].frameCount then FAnimFrameCounter := 0;
 end;
end;

procedure T3dModel.Collision(const Other: T3dModel);
var
  Ray:TRay;
  Mesh1:TMesh;
begin
  // FRayCollision.hit:=false;
  if (FCollisioned) and (Other.FCollisioned) and (not IsModelDead) and (not Other.IsModelDead) then
   begin
    Mesh1:=Model.meshes^;

     if CheckCollisionBoxes(GetMeshBoundingBox(Mesh1),GetMeshBoundingBox(Other.Model.meshes^)) then
     begin
       DoCollision(Other);
       Other.DoCollision(Self);
     end;

    // Ray.position:=Vector3Create(X,Y,Z);
    // Ray.direction:=Vector3Create(AxisX,AxisY,AxisZ);
   //  FRayCollision:=GetRayCollisionModel(ray,Other.Model);

  {if (FRayCollision.hit) and (FRayCollision.distance<0.001) then
   begin
     DoCollision(Other);
     Other.DoCollision(Self);
   end;  }

   end;



end;

procedure T3dModel.Collision;
var I: Integer;
begin
if (FEngine <> nil) and (not IsModelDead) and (Collisioned) then
 begin
   for i := 0 to FEngine.List.Count - 1 do Collision(T3dModel(FEngine.List.Items[i]));
 end;
end;



constructor T3dModel.Create(Engine: TModelEngine);
begin
  FEngine := Engine;
  FEngine.List.Add(Self);
  FScale:=1.0;
  FDrawMode:=dmNormal;
  FColor:=WHITE;
  FAngle:=1.0;
  FPosition:=Vector3Create(0.0,0.0,0.0);
  FAxis:=Vector3Create(0.0,0.0,0.0);
  FScaleEx:= Vector3Create(1.0,1.0,1.0);
  FAngleX:=0.0;
  FIsModelAnimation:=False;
  FAnimationSpeed:=100;
end;

destructor T3dModel.Destroy;
begin
  UnloadTexture(Self.FTexture);
  UnloadModel(Self.FModel);
  inherited Destroy;
end;

procedure TModelEngine.SetCameraPosition(AValue: TVector3);
begin
  FCameraPosition:=AValue;
  FCamera.position:=FCameraPosition;
end;

function TModelEngine.GetCameraPositionX: Single;
begin
  result:=FCamera.position.x;
end;

function TModelEngine.GetCameraPositionY: Single;
begin
  result:=FCamera.position.y;
end;

function TModelEngine.GetCameraPositionZ: Single;
begin
  result:=FCamera.position.z;
end;

procedure TModelEngine.SetCameraPositionX(AValue: Single);
begin
  //if FCameraPositionX=AValue then Exit;
  FCameraPositionX:=AValue;
  FCamera.position.x:=FCameraPositionX;
end;

procedure TModelEngine.SetCameraPositionY(AValue: Single);
begin
  ///if FCameraPositionY=AValue then Exit;
  FCameraPositionY:=AValue;
  FCamera.position.Y:=FCameraPositionY;
end;

procedure TModelEngine.SetCameraPositionZ(AValue: Single);
begin
 // if FCameraPositionZ=AValue then Exit;
  FCameraPositionZ:=AValue;
  FCamera.position.Z:=FCameraPositionZ;
end;

procedure TModelEngine.SetCameraTarget(AValue: TVector3);
begin
  //if FCameraTarget=AValue then Exit;
  FCameraTarget:=AValue;
  FCamera.target:=FCameraTarget;
end;

procedure TModelEngine.SetCameraUp(AValue: TVector3);
begin
  FCameraUp:=AValue;
  FCamera.up:=FCameraUp;
end;


procedure TModelEngine.SetDrawsGrid(AValue: boolean);
begin
  FDrawsGrid:= AValue;
end;

procedure TModelEngine.SetEngineCameraMode(AValue: TModelEngineCameraMode);
begin
  if FEngineCameraMode=AValue then Exit;
  FEngineCameraMode:=AValue;
  case FEngineCameraMode of
    cmCustom         :SetCameraMode(FCamera, CAMERA_CUSTOM);
    cmFree           :SetCameraMode(FCamera, CAMERA_FREE);
    cmOrbital        :SetCameraMode(FCamera, CAMERA_ORBITAL);
    cmFirstPerson    :SetCameraMode(FCamera, CAMERA_FIRST_PERSON);
    cmThirdPerson    :SetCameraMode(FCamera, CAMERA_THIRD_PERSON);
  end;

end;



procedure TModelEngine.SetGridSlices(AValue: longint);
begin
  if FGridSlices=AValue then Exit;
  FGridSlices:=AValue;
end;

procedure TModelEngine.SetGridSpacing(AValue: single);
begin
  if FGridSpacing=AValue then Exit;
  FGridSpacing:=AValue;
end;

procedure TModelEngine.SetShowSkyBox(AValue: boolean);
begin
  if FShowSkyBox=AValue then Exit;
  FShowSkyBox:=AValue;
end;

procedure TModelEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure TModelEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure TModelEngine.CreateSkyBox;

{$I skybox.inc}

var Cube:TMesh;
    mMap:Integer;
begin
  Cube:=GenMeshCube(1.0,1.0,1.0);
  FSkyBox:=LoadModelFromMesh(cube);
  FSkybox.materials[0].shader := LoadShaderFromMemory(vs,fs);
  mMap:=MATERIAL_MAP_CUBEMAP;
  SetShaderValue(FSkybox.materials[0].shader, GetShaderLocation(FSkybox.materials[0].shader,
  'environmentMap'), @mMap , SHADER_UNIFORM_INT);
end;

procedure TModelEngine.Draw();
var
  i: Integer;
begin
  BeginMode3d(FCamera);

  if ShowSkyBox then
   begin
    rlDisableBackfaceCulling();
    rlDisableDepthMask();
    DrawModel(FSkybox, Vector3Create(0, 0, 0), 1.0, white);
    rlEnableBackfaceCulling();
    rlEnableDepthMask();
   end;

  for i := 0 to List.Count - 1 do
  begin
    T3dModel(List.Items[i]).Draw();
  end;
  if FDrawsGrid then DrawGrid(FGridSlices, FGridSpacing);
  EndMode3d();
end;

procedure TModelEngine.ClearDeadModel;
var
  i: Integer;
begin
  for i := 0 to DeadList.Count - 1 do
  begin
    if DeadList.Count >= 1 then
    begin
      if T3dModel(DeadList.Items[i]).IsModelDead = True then
      begin
        T3dModel(DeadList.Items[i]).FEngine.List.Remove(DeadList.Items[i]);
      end;
    end;
  end;
  DeadList.Clear;
end;

procedure TModelEngine.Move(MoveCount: Double);
var
  i: Integer;
begin
   UpdateCamera(@FCamera); // Update camera
  for i := 0 to List.Count - 1 do
  begin
    T3dModel(List.Items[i]).Update3dModelAnimations(MoveCount);
    T3dModel(List.Items[i]).Move(MoveCount);
  end;
end;

procedure TModelEngine.LoadSkyBox(FileName: String);
var img:TImage;
begin
   img := LoadImage(PChar(FileName));
   FSkybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture := LoadTextureCubemap(img, CUBEMAP_LAYOUT_AUTO_DETECT);
   UnloadImage(img);
end;

constructor TModelEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;
  FCamera.position := Vector3Create(3.0, 4.0, 0.0);
  FCamera.target := Vector3Create(0.0, 0.5, 0.0);
  FCamera.up := Vector3Create(0.0, 1.0, 0.0);
  FCamera.fovy := 75.0;
  FCamera.projection := CAMERA_PERSPECTIVE;
  SetEngineCameraMode(cmCustom);
  FGridSpacing:=0.5;
  FGridSlices:=10;
  FShowSkyBox:=False;
  CreateSkyBox;
end;

destructor TModelEngine.Destroy;
var
  i: Integer;
begin
  UnloadShader(FSkybox.materials[0].shader);
  UnloadTexture(FSkybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture);
  UnloadModel(FSkybox);        // Unload skybox model

  for i := 0 to List.Count - 1 do
  begin
    T3dModel(List.Items[i]).Destroy;
  end;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.

