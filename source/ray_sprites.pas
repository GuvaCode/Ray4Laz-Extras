unit ray_sprites;

{$mode objfpc}{$H+}
interface

uses ray_header, ray_math, classes,sysutils;

type
  TJumpState = (jsNone, jsJumping, jsFalling);

  { T2DEngine }
  T2DEngine = class
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
    FVector: TVector2;
    FZ: Single;
    FScale: Single;
  protected
    FEngine: T2DEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
  public
    FTexture: TGameTexture;
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
    constructor Create(Engine: T2DEngine; Texture: TGameTexture); virtual;
    destructor Destroy; override;
    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FZ write SetOrder;
    property Scale: Single read FScale write SetScale;
  end;


    { TRayAnimatedSprite }

    TRayAnimatedSprite = class(TRaySprite)
  protected
    FDoAnimated: Boolean;
    FSplited: array of TRect;
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

    PatternCount: Integer;
    PatternDeltaX: Integer;
    PatternDeltaY: Integer;

    procedure Split();
    procedure Split2();
    procedure Split3();

    procedure Draw();
    procedure Move(MoveCount: Double); override;

    procedure DoAnim(Looped: Boolean; Start: Integer; Count: Integer;
      Speed: Single);

    constructor Create(Engine: T2DEngine; Texture: TGameTexture); override;
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

procedure TRayAnimatedSprite.Split();
 var
  i: Integer;
begin
  SetLength(FSplited, PatternCount + 1);
  for i := 0 to PatternDeltaY - 1 do
  begin
    if i = 0 then
    begin
      FSplited[PatternCount].Left := 0;
      FSplited[PatternCount].Top := 0;
      FSplited[PatternCount].Right := PatternWidth;
      FSplited[PatternCount].Bottom := PatternHeight;
      Inc(PatternCount);
    end; // if i = 0
    if i >= 1 then
    begin

      SetLength(FSplited, PatternCount + 1);

      FSplited[PatternCount].Left := 0;
      FSplited[PatternCount].Top := PatternHeight * i;
      FSplited[PatternCount].Right := PatternWidth;
      FSplited[PatternCount].Bottom := PatternHeight * (i + 1);

      Inc(PatternCount);

    end; // if i >= 1

  end; // for
end;

procedure TRayAnimatedSprite.Split2();
 var
   i: Integer;
 begin

   SetLength(FSplited, PatternCount + 1);

   for i := 0 to PatternDeltaX - 1 do
   begin

     if i = 0 then
     begin

       FSplited[PatternCount].Left := 0;
       FSplited[PatternCount].Top := 0;
       FSplited[PatternCount].Right := PatternWidth;
       FSplited[PatternCount].Bottom := PatternHeight;

       Inc(PatternCount);

     end; // if i = 0

     if i >= 1 then
     begin

       SetLength(FSplited, PatternCount + 1);

       FSplited[PatternCount].Left := PatternWidth * (i);
       FSplited[PatternCount].Top := 0;
       FSplited[PatternCount].Right := PatternWidth * (i + 1);
       FSplited[PatternCount].Bottom := PatternHeight;

       Inc(PatternCount);

     end; // if i >= 1

   end; // for

end;

procedure TRayAnimatedSprite.Split3();
 var
   j: Integer;

   procedure CallSpliter(NextTop, NextHeight: Integer);
   var
     i: Integer;
   begin

     for i := 0 to PatternDeltaX - 1 do
     begin

       if i = 0 then
       begin

         SetLength(FSplited, PatternCount + 1);

         FSplited[PatternCount].Left := 0;
         FSplited[PatternCount].Top := NextTop;
         FSplited[PatternCount].Right := PatternWidth;
         FSplited[PatternCount].Bottom := NextHeight;

         Inc(PatternCount);

       end; // if i = 0

       if i >= 1 then
       begin

         SetLength(FSplited, PatternCount + 1);

         FSplited[PatternCount].Left := PatternWidth * (i);
         FSplited[PatternCount].Top := NextTop;
         FSplited[PatternCount].Right := PatternWidth * (i + 1);
         FSplited[PatternCount].Bottom := NextHeight;

         Inc(PatternCount);

       end; // if i >= 1

     end; // for

   end;

 begin

   for j := 0 to PatternDeltaY - 1 do
   begin

     if j = 0 then
     begin

       CallSpliter(0, PatternHeight);

     end
     else
     begin

       CallSpliter(PatternHeight * j, PatternHeight * (j + 1));

     end;

   end;


end;

procedure TRayAnimatedSprite.Draw();
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
           RectangleSet(@Source,
          FTexture.Pattern[FTextureIndex].Width div Round(AnimPos),
          FTexture.Pattern[FTextureIndex].Height div Round(AnimPos),

           FTexture.Pattern[FTextureIndex].Width  ,
           FTexture.Pattern[FTextureIndex].Height);

           RectangleSet(@Dest,FEngine.FCamera.target.x + X,FEngine.FCamera.target.y + Y ,FTexture.Pattern[FTextureIndex].Width, FTexture.Pattern[FTextureIndex].Height);

           Vector2Set(@WH,FTexture.Pattern[FTextureIndex].Width/2,FTexture.Pattern[FTextureIndex].Height/2);
           AlphaColor:=White;  AlphaColor.a:=alpha;

           DrawTextureTiled(FTexture.Texture[FTextureIndex], Source, Dest, WH, Angle, ScaleX, AlphaColor);
        end;
     end;
   end;
   DrawText(Pchar(inttostr(Trunc(animpos))), 140, 20, 20, BLACK);

end;

procedure TRayAnimatedSprite.Move(MoveCount: Double);
begin
  //inherited Move(MoveCount);
  if AnimSpeed > 0 then
  begin

    AnimPos := AnimPos + AnimSpeed;
    FPatternIndex := Trunc(AnimPos);

    if (Trunc(AnimPos) > AnimStart + AnimCount) then
    begin

      if (Trunc(AnimPos)) = AnimStart + AnimCount then

        if AnimLooped then
        begin
          AnimPos := AnimStart;
          FPatternIndex := Trunc(AnimPos);
        end
        else
        begin
          AnimPos := AnimStart + AnimCount - 1;
          FPatternIndex := Trunc(AnimPos);
        end;
    end;

    if FDoAnimated = True then
    begin
      if Trunc(AnimPos) >= AnimCount + 1 then
      begin

        FDoAnimated := False;
        AnimLooped := False;

        AnimSpeed := 0;
        AnimCount := 0;

        AnimPos := AnimStart;
        FPatternIndex := Trunc(AnimPos);
      end;
    end;

    if Trunc(AnimPos) < AnimStart then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Trunc(AnimPos);
    end;

    if Trunc(AnimPos) > AnimCount then
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

constructor TRayAnimatedSprite.Create(Engine: T2DEngine; Texture: TGameTexture);
begin
  inherited Create(Engine, Texture);
  FAnimated := True;
end;

destructor TRayAnimatedSprite.Destroy;
var
  i: Integer;
begin
  for i := 0 to PatternCount - 1 do
  begin
    FSplited[i].Left := 0;
    FSplited[i].Top := 0;
    FSplited[i].Right := 0;
    FSplited[i].Bottom := 0;
  end;
  SetLength(FSplited, 0);
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

constructor TRaySprite.Create(Engine: T2DEngine; Texture: TGameTexture);
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
  Visible := True; // Displaymode Width/Height
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
//  tex_SetFrameSize(Texture[Count - 1], Width, Height);
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
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  inherited Destroy;
end;

{ T2DEngine }
procedure T2DEngine.SetCamera(AValue: TCamera2D);
begin
  FCamera := AValue;
end;

procedure T2DEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure T2DEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure T2DEngine.Draw();
var  i: Integer;
begin
 for i := 0 to List.Count - 1 do
   begin
    if TRaySprite(List.Items[i]).FAnimated = False then TRaySprite(List.Items[i]).Draw
    else TRayAnimatedSprite(List.Items[i]).Draw;
   end;
end;

procedure T2DEngine.ClearDeadSprites;
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

procedure T2DEngine.Move(MoveCount: Double);
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


procedure T2DEngine.SetZOrder();
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

constructor T2DEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;
  FCamera.target.x:=0;
end;

destructor T2DEngine.Destroy;
var i: Integer;
begin
  for i := 0 to List.Count - 1 do  TRaySprite(List.Items[i]).Destroy;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.


