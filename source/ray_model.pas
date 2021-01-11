unit ray_model;

{$mode objfpc}{$H+}

interface

uses
  ray_headers, classes;

type

  { T3DEngine }

  T3DEngine = class
   private
     FWorld: TVector3;
     FCamera: TCamera;
     procedure SetCamera(Value: TCamera3D);
     procedure SetWorldX(Value: Single);
     procedure SetWorldY(Value: Single);
   public
     List: TList;
     DeadList: TList;

     procedure Draw();
     procedure ClearDeadModel;
     procedure Move(DT: Double);

     constructor Create;
     destructor Destroy; override;
     property Camera: TCamera read FCamera write SetCamera;

     property WorldX: Single read FWorld.X write SetWorldX;
     property WorldY: Single read FWorld.Y write SetWorldY;
   end;

  { TModelSprite }

  TModelSprite = class
  private
    FVector: TVector3;
  protected
    FEngine: T3DEngine;
    FModel: TModel;
  public
    Angle: Single;
    IsModelDead: Boolean;
    Visible: Boolean;
    procedure Draw();
    procedure Move(DT: Double); virtual;
    procedure Dead();
    constructor Create(Engine: T3DEngine; ModelFileName:String); virtual;
    destructor Destroy; override;
    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FVector.Z write FVector.Z;
 end;


implementation

{ TModelSprite }

procedure TModelSprite.Draw();
begin
  if Assigned(FEngine) then
  begin
   //BeginMode3d(FEngine.Camera);
    DrawModel(FModel, FVector, 2.0, WHITE); // Draw 3d model with texture
 // EndMode3d();
  end;
end;

procedure TModelSprite.Move(DT: Double);
begin
 // UpdateCamera(@FEngine.Camera);
end;

procedure TModelSprite.Dead();
begin
   if IsModelDead = False then
  begin
    IsModelDead := True;
    FEngine.DeadList.Add(Self);
    Self.Visible := False;
  end;
end;

constructor TModelSprite.Create(Engine: T3DEngine; ModelFileName: String);
begin
  FEngine := Engine;
  FEngine.List.Add(Self);
  FModel:=LoadModel(PChar(ModelFileName));
end;

destructor TModelSprite.Destroy;
begin
  inherited Destroy;
end;

{ T3DEngine }

procedure T3DEngine.SetCamera(Value: TCamera3D);
begin
  FCamera := Value;
end;

procedure T3DEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure T3DEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure T3DEngine.Draw();
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
  begin
    //BeginMode3d(FCamera);
    TModelSprite(List.Items[i]).Draw();
    //EndMode3d();
  end;
end;

procedure T3DEngine.ClearDeadModel;
var
  i: Integer;
begin
  for i := 0 to DeadList.Count - 1 do
  begin
    if DeadList.Count >= 1 then
    begin
      if TModelSprite(DeadList.Items[i]).IsModelDead = True then
      begin
        TModelSprite(DeadList.Items[i]).FEngine.List.Remove(DeadList.Items[i]);
      end;
    end;
  end;
  DeadList.Clear;
end;

procedure T3DEngine.Move(DT: Double);
var
  i: Integer;
begin
  UpdateCamera(@FCamera); // Update camera
  for i := 0 to List.Count - 1 do
  begin

    TModelSprite(List.Items[i]).Move(DT);
  end;

end;



constructor T3DEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;
end;

destructor T3DEngine.Destroy;
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
  begin
    TModelSprite(List.Items[i]).Destroy;
  end;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.

