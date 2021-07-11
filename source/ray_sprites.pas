unit ray_sprites;

{$mode objfpc}{$H+}
{$WARN 5027 off : Local variable "$1" is assigned but never used}
{$WARN 5024 off : Parameter "$1" not used}
interface

uses ray_header, ray_math, classes,sysutils;

type
  TJumpState = (jsNone, jsJumping, jsFalling);
  TFlipState = (fsNormal, fsX , fsY , fsXY);
  TCollideMode = (cmRectangle, cmCircles, cmPointRec, cmPointCircle);



  { TSpriteEngine }
  TSpriteEngine = class
  private
    FCamera: TCamera2D;
    FWorld: TVector2;
    procedure SetCamera(AValue: TCamera2D);
    procedure SetWorldX(Value: Single);
    procedure SetWorldY(Value: Single);
  public
    List: TList;
    DeadList: TList;
    procedure Draw();
    procedure ClearDeadSprites;
    procedure Move(MoveCount:Double);
    procedure SetZOrder();
    constructor Create;
    destructor Destroy; override;
    property Camera: TCamera2D read FCamera write SetCamera;
    property WorldX: Single read FWorld.X write SetWorldX;
    property WorldY: Single read FWorld.Y write SetWorldY;
  end;

  TPattern = record
    Height, Width: Integer;
  end;

  { TGameTexture }
  TGameTexture = class
  public
    Count: Integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
   end;

  { TRaySprite }
  TRaySprite = class
  private
    FAnimated: Boolean;
    FCollideMode: TCollideMode;
    FCollidePos: TVector2;
    FCollisioned: Boolean;
    FVector: TVector2;
    FZ: Single;
    FScale: Single;
  protected
    FEngine: TSpriteEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
    procedure DoCollision(const Sprite: TRaySprite); virtual;
  public
    FTexture: TGameTexture;
    FlipState : TFlipState;
    Alpha: Byte;
    Angle: Single;
    IsSpriteDead: Boolean;
    DrawMode: Integer;
    ScaleX, ScaleY: Single;
    Visible: Boolean;
    Pattern: TNPatchInfo;
    procedure Draw();
    procedure Move(MoveCount: Double); virtual;
    procedure Dead();
    procedure SetOrder(Value: Single);
    procedure SetScale(Value: Single);
    procedure Collision(const Other: TRaySprite); overload; virtual;
    procedure Collision; overload; virtual;
    constructor Create(Engine: TSpriteEngine; Texture: TGameTexture); virtual;
    destructor Destroy; override;
    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FZ write SetOrder;
    property Scale: Single read FScale write SetScale;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
    property CollideMode: TCollideMode read FCollideMode write FCollideMode;
    property CollidePos: TVector2 read FCollidePos write FCollidePos;

  end;


  { TRayAnimatedSprite }
  TRayAnimatedSprite = class(TRaySprite)
  protected
    FDoAnimated: Boolean;
    FPatternIndex: Integer;
    FPatternHeight: Integer;
    FPatternWidth: Integer;
    procedure SetPatternHeight(Value: Integer);
    procedure SetPatternWidth(Value: Integer);
  public
    AnimLooped: Boolean;
    AnimStart: Integer;
    AnimCount: Integer;
    AnimSpeed: Single;
    AnimPos: Single;

    procedure Draw();
    procedure Move(MoveCount: Double); override;

    procedure DoAnim(Looped: Boolean; Start: Integer; Count: Integer; Speed: Single);

    constructor Create(Engine: TSpriteEngine; Texture: TGameTexture); override;
    destructor Destroy; override;

    property PatternHeight: Integer read FPatternHeight write SetPatternHeight;
    property PatternWidth: Integer read FPatternWidth write SetPatternWidth;
  end;


implementation

{ TRayAnimatedSprite }
procedure TRayAnimatedSprite.SetPatternHeight(Value: Integer);
begin
  FPatternHeight := Value;
  Pattern.Bottom := Value;
end;

procedure TRayAnimatedSprite.SetPatternWidth(Value: Integer);
begin
  FPatternWidth := Value;
  Pattern.Right := Value;
end;

procedure TRayAnimatedSprite.Draw();
var Source: TRectangle;
    Dest: TRectangle;
    Orig:TVector2;
    AlphaColor:TColor;
    ox,oy:single;
    FramesPerLine: integer;
    NumLines: integer;

begin
   if TextureIndex  <> -1 then
   begin
     if Assigned(FEngine) then
     begin
        if Visible then
        begin
         FramesPerLine:=Ftexture.Texture[FTextureIndex].width div FTexture.Pattern[FTextureIndex].Width;
         NumLines:=Ftexture.Texture[FTextureIndex].height div FTexture.Pattern[FTextureIndex].Height;
         ox := (Round(AnimPos) mod FramesPerLine) * FTexture.Pattern[FTextureIndex].Width;

           if (Round(AnimPos) >= FramesPerLine)  then
           begin
            {$WARNINGS OFF}
             oy:=oy + FTexture.Pattern[FTextureIndex].Height;
            {$WARNINGS ON}
           end;

           case FlipState of
            fsNormal :
              RectangleSet(@Source,OX,OY,FTexture.Pattern[FTextureIndex].Width,FTexture.Pattern[FTextureIndex].Height);
            fsX:
              RectangleSet(@Source,OX,OY,-FTexture.Pattern[FTextureIndex].Width,FTexture.Pattern[FTextureIndex].Height);
            fsY:
              RectangleSet(@Source,OX,OY,FTexture.Pattern[FTextureIndex].Width,-FTexture.Pattern[FTextureIndex].Height);
            fsXY:
              RectangleSet(@Source,OX,OY,-FTexture.Pattern[FTextureIndex].Width,-FTexture.Pattern[FTextureIndex].Height);
           end;

           RectangleSet(@Dest,
           FEngine.FCamera.target.x + x ,
           FEngine.FCamera.target.y + y ,
           FTexture.Pattern[FTextureIndex].Width* scale, FTexture.Pattern[FTextureIndex].Height* scale);

           Vector2Set(@Orig,FTexture.Pattern[FTextureIndex].Width/2 * Scale,
           FTexture.Pattern[FTextureIndex].Height/2 * Scale);

           AlphaColor:=White; AlphaColor.a:=alpha;

           DrawTexturePro(FTexture.Texture[FTextureIndex], Source, Dest,Orig,Angle,AlphaColor);

        end;
     end;
   end;
end;

procedure TRayAnimatedSprite.Move(MoveCount: Double);
begin
   if AnimSpeed > 0 then
  begin
    AnimPos := AnimPos + AnimSpeed * MoveCount;
    FPatternIndex := Round(AnimPos);

    if (Round(AnimPos) > AnimStart + AnimCount) then
    begin

      if (Round(AnimPos)) = AnimStart + AnimCount then

        if AnimLooped then
        begin
          AnimPos := AnimStart;
          FPatternIndex := Round(AnimPos);
        end
        else
        begin
          AnimPos := AnimStart + AnimCount - 1;
          FPatternIndex := Round(AnimPos);
        end;
    end;

    if FDoAnimated = True then
    begin
      if Round(AnimPos) >= AnimCount + 1 then
      begin

        FDoAnimated := False;
        AnimLooped := False;

        AnimSpeed := 0;
        AnimCount := 0;

        AnimPos := AnimStart;
        FPatternIndex := Round(AnimPos);
      end;
    end;

    if Round(AnimPos) < AnimStart then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Round(AnimPos);
    end;

    if Round(AnimPos) > AnimCount then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Trunc(AnimPos);
    end;
  end; // if AnimSpeed > 0
end;

procedure TRayAnimatedSprite.DoAnim(Looped: Boolean; Start: Integer;
  Count: Integer; Speed: Single);
begin
  FDoAnimated := True;
  AnimLooped := Looped;
  AnimStart := Start;
  AnimCount := Count;
  AnimSpeed := Speed;
end;

constructor TRayAnimatedSprite.Create(Engine: TSpriteEngine; Texture: TGameTexture);
begin
  inherited Create(Engine, Texture);
  FAnimated := True;
  FlipState:= fsNormal;
end;

destructor TRayAnimatedSprite.Destroy;
begin
  inherited Destroy;
end;

{ TRaySprite }
procedure TRaySprite.SetTextureName(Value: string);
var i: Integer;
begin
  FTextureName := Value;
  for i := 0 to Length(FTexture.TextureName) - 1 do
  begin
    if lowercase(FTextureName) = lowercase(FTexture.TextureName[i]) then
    begin
      TextureIndex := i;
      Pattern.Right := FTexture.Pattern[i].Height;
      Pattern.Bottom := FTexture.Pattern[i].Width;
      Exit;
    end;
  end;
  TextureIndex := -1;
end;

procedure TRaySprite.SetTextureIndex(Value: Integer);
begin
  FTextureIndex := Value;
  Pattern.Right := FTexture.Pattern[FTextureIndex].Height;
  Pattern.Bottom := FTexture.Pattern[FTextureIndex].Width;
end;

procedure TRaySprite.DoCollision(const Sprite: TRaySprite);
begin

end;

procedure TRaySprite.Draw();
var Source: TRectangle;
    Dest: TRectangle;
    WH:TVector2;
    AlphaColor:TColor;
begin
   if TextureIndex  <> -1 then
   begin
     if Assigned(FEngine) then
     begin
        if Visible then
        begin
           RectangleSet(@Source,0,0,FTexture.Pattern[FTextureIndex].Width, FTexture.Pattern[FTextureIndex].Height);
           RectangleSet(@Dest,FEngine.FCamera.target.x + X,FEngine.FCamera.target.y + Y ,FTexture.Pattern[FTextureIndex].Width, FTexture.Pattern[FTextureIndex].Height);
           Vector2Set(@WH,FTexture.Pattern[FTextureIndex].Width/2,FTexture.Pattern[FTextureIndex].Height/2);
           AlphaColor:=White;  AlphaColor.a:=alpha;
           DrawTextureTiled(FTexture.Texture[FTextureIndex], Source, Dest, WH, Angle, ScaleX, AlphaColor);
        end;
     end;
   end;
end;

procedure TRaySprite.Move(MoveCount: Double);
begin

end;

procedure TRaySprite.Dead();
begin
   if IsSpriteDead = False then
  begin
    IsSpriteDead := True;
    FEngine.DeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure TRaySprite.SetOrder(Value: Single);
begin
  if FZ <> Value then FZ := Value;
  FEngine.SetZOrder;
end;

procedure TRaySprite.SetScale(Value: Single);
begin
  FScale := Value;
  ScaleX := FScale;
  ScaleY := FScale;
end;

procedure TRaySprite.Collision(const Other: TRaySprite);
var IsCollide: Boolean;
begin
  IsCollide := False;
  if (FCollisioned) and (Other.FCollisioned) and (not IsSpriteDead)and (not Other.IsSpriteDead) then
  begin

   if CheckCollisionRecs(RectangleCreate(Other.X-64, Other.Y-64,128,128),RectangleCreate( X-64,Y-64,128,128))
    then
    begin
      DrawRectangle(round(X)-64,Round(y)-64,128,128,Red);
      DrawRectangle(Round(Other.x)-64,Round(Other.y)-64,128,128,blue);
      DrawText('Collizion',0,0,10,ColorCreate(0,128,0,255));
    end
   else  DrawText('NO Colizion',0,0,10,ColorCreate(0,128,0,255));


   //RectangleSet(@Dest,FEngine.FCamera.target.x + X,FEngine.FCamera.target.y + Y ,FTexture.Pattern[FTextureIndex].Width, FTexture.Pattern[FTextureIndex].Height);


  end;


  //DrawRectangleRec(GetCollisionRec(RectangleCreate(X,Y,128,128),RectangleCreate(Other.X,Other.Y,128,128)),Red);

end;

procedure TRaySprite.Collision;
  var
   i: Integer;
begin
     if (FEngine<>nil) and (not IsSpriteDead) and (Collisioned) then
     begin
          for i:=0 to FEngine.List.Count-1 do
              Self.Collision(TRaySprite(FEngine.List.Items[i]));
     end;

end;

constructor TRaySprite.Create(Engine: TSpriteEngine; Texture: TGameTexture);
begin
  FAnimated := False;
  FEngine := Engine;
  FEngine.List.Add(Self);
  FTexture := Texture;
  Pattern.Left := 0;
  Pattern.Top := 0;
  Alpha := 255;
  ScaleX := 1.0;
  ScaleY := 1.0;
  Scale  := 1.0;
  Visible := True;
end;


destructor TRaySprite.Destroy;
begin
  inherited Destroy;
end;

{ TGameTexture }
function TGameTexture.LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
begin
   if not fileexists(PChar(FileName)) then
  begin
    Result := False;
    Exit;
  end;
  SetLength(Texture, Count + 1);
  SetLength(TextureName, Count + 1);
  SetLength(Pattern, Count + 1);
  Inc(Count);
  TextureName[Count - 1] := FileName;
  Pattern[Count - 1].Height := Height;
  Pattern[Count - 1].Width := Width;
  Texture[Count - 1] := LoadTexture(PChar(FileName));
  Result := True
end;

constructor TGameTexture.Create;
begin
end;

destructor TGameTexture.Destroy;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TextureName[i] := '';
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
    UnloadTexture(Texture[i]);
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  inherited Destroy;
end;

{ TSpriteEngine }
procedure TSpriteEngine.SetCamera(AValue: TCamera2D);
begin
  FCamera := AValue;
end;

procedure TSpriteEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure TSpriteEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure TSpriteEngine.Draw();
var  i: Integer;
begin
 for i := 0 to List.Count - 1 do
   begin
    if TRaySprite(List.Items[i]).FAnimated = False then TRaySprite(List.Items[i]).Draw
    else TRayAnimatedSprite(List.Items[i]).Draw;
   end;
end;

procedure TSpriteEngine.ClearDeadSprites;
var i: Integer;
begin
  for i := 0 to DeadList.Count - 1 do
  begin
    if DeadList.Count >= 1 then
    begin
      if TRaySprite(DeadList.Items[i]).IsSpriteDead = True then
      begin
        TRaySprite(DeadList.Items[i]).FEngine.List.Remove(DeadList.Items[i]);
      end;
    end;
  end;
  DeadList.Clear;
end;

procedure TSpriteEngine.Move(MoveCount: Double);
var i: Integer;
begin
  for i := 0 to List.Count - 1 do
  begin
    if TRaySprite(List.Items[i]).FAnimated = False then
       TRaySprite(List.Items[i]).Move(MoveCount)
    else
      TRayAnimatedSprite(List.Items[i]).Move(MoveCount);
  end;
end;


procedure TSpriteEngine.SetZOrder();
var i: Integer; Done: Boolean;
begin
  Done := False;
  repeat
    for i := List.Count - 1 downto 0 do
    begin
     if i = 0 then
      begin
        Done := True;
        break;
      end;
      if TRaySprite(List.Items[i]).Z < TRaySprite(List.Items[i - 1]).Z then
      begin
        List.Move(i, i - 1);
        break;
      end;
    end;
  until Done;
end;

constructor TSpriteEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;
  FCamera.target.x:=0;
end;

destructor TSpriteEngine.Destroy;
var i: Integer;
begin
  for i := 0 to List.Count - 1 do  TRaySprite(List.Items[i]).Destroy;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.


