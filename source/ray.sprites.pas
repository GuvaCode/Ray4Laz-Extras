unit ray.sprites;

{$mode objfpc}{$H+}


interface

uses
  ray_headers, Classes, SysUtils, Generics.Collections, PXT.TypesEx;

type
  TCollideMode = (cmCircle, cmRect, cmQuadrangle, cmPolygon);
  TBlendingEffect=( BLEND_ALPHA, BLEND_ADDITIVE, BLEND_MULTIPLIED, BLEND_SUBTRACT_COLORS, BLEND_CUSTOM);

  TFrameRec = record
    FrameName: string;
    Frames: array of Cardinal;
  end;
  { ESpriteError }

  ESpriteError = class(Exception);

  TSpriteEngine = class;

  TSpriteClass = class of TSprite;

  { TAnimations }

  TAnimations = class
  private
    FrameData: array of TFrameRec;
    SearchObjects: array of Integer;
    SearchDirty: Boolean;
    function GetItem(Index: Integer): TFrameRec;
    function GetItemCount(): Integer;
    procedure InitSearchObjects();
    procedure SwapSearchObjects(Index1, Index2: Integer);
    function CompareSearchObjects(Obj1, Obj2: TFrameRec): Integer;
    function SplitSearchObjects(Start, Stop: Integer): Integer;
    procedure SortSearchObjects(Start, Stop: Integer);
    procedure UpdateSearchObjects();
    function GetFrame(const Name: string): TFrameRec;
  public
    property Items[Index: Integer]: TFrameRec read GetItem; Default;
    property ItemCount: Integer read GetItemCount;
    property Frame[const Name: string]: TFrameRec read GetFrame;
    function IndexOf(const Name: string): Integer; overload;
    procedure Remove(Index: Integer);
    procedure AddFrames(FrameName: string; Frames: array of Cardinal); overload;
    procedure RemoveAll();
    procedure MarkSearchDirty();
    constructor Create();
    destructor Destroy(); override;
  end;

   { TSprite }

   TSprite = class
  private
    FCollidePolygon: TPolygon;
    FCollidePos: TPoint;
    FCollideQuadrangle: TPoint4;
    FCollideRect: TRect;
    FEngine: TSpriteEngine;
    FParent: TSprite;
    FList: specialize TList<TSprite>;
    FDrawList: specialize TList<TSprite>;
    FDeaded: Boolean;
    FWidth: Integer;
    FHeight: Integer;
    FName: string;
    FX, FY: Single;
    FZ: Integer;
    FWorldX, FWorldY: Single;
    FVisible: Boolean;
    FBlendingEffect: TBlendingEffect;
    FCollisioned: Boolean;
    FDoCollision: Boolean;
    FImageName: string;
    FImageLib: specialize TDictionary<string, TTexture>;
    FImageIndex: Integer;
    FMoved: Boolean;
    FTruncMove: Boolean;
    FCollideRadius: Integer;
    FTag: Integer;
    FCollideMode: TCollideMode;
    FZSet: Boolean;
    procedure Add(Sprite: TSprite);
    procedure Remove(Sprite: TSprite);
    procedure AddDrawList(Sprite: TSprite);
    procedure Draw; virtual;
    function GetCount: Integer;
    function GetItem(Index: Integer): TSprite;
    function GetImageWidth: Integer;
    function GetImageHeight: Integer;
  protected
    procedure DoDraw; virtual;
    procedure DoMove(const MoveCount: Single); virtual;
    procedure DoCollision(const Sprite: TSprite); virtual;
    procedure SetName(const Value: string); virtual;
    procedure SetImageName(const Value: string); virtual;
    procedure SetX(const Value: Single); virtual;
    procedure SetY(const Value: Single); virtual;
    procedure SetZ(const Value: Integer); virtual;
  public
    constructor Create(const AParent: TSprite); virtual;
    destructor Destroy; override;
    procedure Assign(const Value: TSprite); virtual;
    procedure Clear;
    procedure Move(const MoveCount: Single);
    procedure SetPos(X, Y: Single); overload;
    procedure SetPos(X, Y: Single; Z: Integer); overload;
    procedure Collision(const Other: TSprite); overload; virtual;
    procedure Collision; overload; virtual;
    procedure Dead;
    property Visible: Boolean read FVisible write FVisible;
    property X: Single read FX write SetX;
    property Y: Single read FY write SetY;
    property Z: Integer read FZ write SetZ;
    property ImageName: string read FImageName write FImageName;
    property ImageLib: specialize TDictionary<string, TTexture> read FImageLib write FImageLib;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property ImageWidth: Integer read GetImageWidth;
    property ImageHeight: Integer read GetImageHeight;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property WorldX: Single read FWorldX write FWorldX;
    property WorldY: Single read FWorldY write FWorldY;
    property BlendingEffect: TBlendingEffect read FBlendingEffect write FBlendingEffect;
    property Name: string read FName write SetName;
    property Moved: Boolean read FMoved write FMoved;
    property TruncMove: Boolean read FTruncMove write FTruncMove;
    property CollidePos: TPoint read FCollidePos write FCollidePos;
    property CollideRadius: Integer read FCollideRadius write FCollideRadius;
    property CollideRect: TRect read FCollideRect write FCollideRect;
    property CollideQuadrangle: TPoint4 read FCollideQuadrangle write FCollideQuadrangle;
    property CollidePolygon: TPolygon read FCollidePolygon write FCollidePolygon;
    property CollideMode: TCollideMode read FCollideMode write FCollideMode;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
    property Items[Index: Integer]: TSprite read GetItem; Default;
    property SpriteList: specialize TList<TSprite> read FList write FList;
    property Count: Integer read GetCount;
    property Engine: TSpriteEngine read FEngine write FEngine;
    property Parent: TSprite read FParent;
    property Tag: Integer read FTag write FTag;
  end;

 { TSpriteEngine }
  TSpriteEngine = class(TSprite)
  private
    FAllCount: Integer;
    FDeadList: TList;
    FDrawCount: Integer;
  //  FWorldX, FWorldY: Single;
    FObjectsSelected: Boolean;
    FGroupCount: Integer;
    FGroups: array of TList;
    FCurrentSelected: TList;
    FVisibleWidth: Integer;
    FVisibleHeight: Integer;
    FDoMouseEvent: Boolean;
    FZCounter: Integer;
  protected
    procedure SetGroupCount(AGroupCount: Integer); virtual;
    function GetGroup(Index: Integer): Classes.TList; virtual;
  public
    constructor Create(const AParent: TSprite); override;
    destructor Destroy; override;
    procedure Draw; override;
    procedure DrawEx(TypeList: array of string);
    procedure Dead;
    function Select(Point: TPoint; Filter: array of TSpriteClass; Add_: Boolean = False): TSprite;
      overload;
    function Select(Point: TPoint; Add_: Boolean = False): TSprite; overload;
    procedure ClearCurrent;
    procedure ClearGroup(GroupNumber: Integer);
    procedure GroupToCurrent(GroupNumber: Integer; Add_: Boolean = False);
    procedure CurrentToGroup(GroupNumber: Integer; Add_: Boolean = False);
    procedure GroupSelect(const Area: TRect; Filter: array of TSpriteClass; Add_: Boolean = False);
      overload;
    procedure GroupSelect(const Area: TRect; Add_: Boolean = False); overload;
    property AllCount: Integer read FAllCount;
    property DrawCount: Integer read FDrawCount;
    property VisibleWidth: Integer read FVisibleWidth write FVisibleWidth;
    property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
    property WorldX: Single read FWorldX write FWorldX;
    property WorldY: Single read FWorldY write FWorldY;
    property CurrentSelected: Classes.TList read FCurrentSelected;
    property ObjectsSelected: Boolean read FObjectsSelected;
    property Groups[index: Integer]: Classes.TList read GetGroup;
    property GroupCount: Integer read FGroupCount write SetGroupCount;
  end;


implementation

{ TSpriteEngine }

procedure TSpriteEngine.SetGroupCount(AGroupCount: Integer);
begin

end;

function TSpriteEngine.GetGroup(Index: Integer): Classes.TList;
begin

end;

constructor TSpriteEngine.Create(const AParent: TSprite);
begin
  inherited Create(AParent);
  FDeadList := Classes.TList.Create;
  FCurrentSelected := Classes.TList.Create;
  GroupCount := 10;
  FVisibleWidth := 800;
  FVisibleHeight := 600;
  FDoMouseEvent := False;
  FZCounter := 3;
end;

destructor TSpriteEngine.Destroy;
begin
  ClearCurrent;
  GroupCount := 0;
  FDeadList.Free;
  inherited Destroy;
  FCurrentSelected.Free;
end;

procedure TSpriteEngine.Draw;
begin
  inherited Draw;
end;

procedure TSpriteEngine.DrawEx(TypeList: array of string);
begin

end;

procedure TSpriteEngine.Dead;
begin

end;

function TSpriteEngine.Select(Point: TPoint; Filter: array of TSpriteClass;
  Add_: Boolean): TSprite;
begin

end;

function TSpriteEngine.Select(Point: TPoint; Add_: Boolean): TSprite;
begin

end;

procedure TSpriteEngine.ClearCurrent;
begin
   while CurrentSelected.Count <> 0 do
    //TSpriteEx(CurrentSelected[CurrentSelected.Count - 1]).Selected := False;
  FObjectsSelected := False;
end;

procedure TSpriteEngine.ClearGroup(GroupNumber: Integer);
var
  Index: Integer;
  Group: TList;
begin
  Group := Groups[GroupNumber];
  if Group <> nil then
    //for Index := 0 to Group.Count - 1 do
     // TSpriteEx(Group[Index]).Selected := False;
end;

procedure TSpriteEngine.GroupToCurrent(GroupNumber: Integer; Add_: Boolean);
begin

end;

procedure TSpriteEngine.CurrentToGroup(GroupNumber: Integer; Add_: Boolean );
begin

end;

procedure TSpriteEngine.GroupSelect(const Area: TRect;
  Filter: array of TSpriteClass; Add_: Boolean = false);
var
  Index, Index2: Integer;
  Sprite: TSprite;
begin
  Assert(Length(Filter) <> 0, 'Filter = []');
  if not Add_ then
    ClearCurrent;
  if Length(Filter) = 1 then
  begin
    for Index := 0 to Count - 1 do
    begin
     { Sprite := TSpriteEx(Items[Index]);
      if (Sprite is Filter[0]) and OverlapRect(TSpriteEx(Sprite).GetBoundsRect, Area) then
        TSpriteEx(Sprite).Selected := True;}
    end
  end
  else
  begin
    for Index := 0 to Count - 1 do
    begin
      Sprite := Items[Index];
      for Index2 := 0 to High(Filter) do
      begin
        {if (Sprite is Filter[Index2]) and OverlapRect(TSpriteEx(Sprite).GetBoundsRect, Area) then
        begin
          TSpriteEx(Sprite).Selected := True;
          Break;
        end;  }
      end;
    end
  end;
  FObjectsSelected := CurrentSelected.Count <> 0;
end;

procedure TSpriteEngine.GroupSelect(const Area: TRect; Add_: Boolean = false);
begin
  GroupSelect(Area, [TSprite], Add_);
end;


{ TSprite }

procedure TSprite.Add(Sprite: TSprite);
begin

end;

procedure TSprite.Remove(Sprite: TSprite);
begin

end;

procedure TSprite.AddDrawList(Sprite: TSprite);
begin

end;

procedure TSprite.Draw;
begin

end;

function TSprite.GetCount: Integer;
begin

end;

function TSprite.GetItem(Index: Integer): TSprite;
begin

end;

function TSprite.GetImageWidth: Integer;
begin

end;

function TSprite.GetImageHeight: Integer;
begin

end;

procedure TSprite.DoDraw;
begin

end;

procedure TSprite.DoMove(const MoveCount: Single);
begin

end;

procedure TSprite.DoCollision(const Sprite: TSprite);
begin

end;

procedure TSprite.SetName(const Value: string);
begin

end;

procedure TSprite.SetImageName(const Value: string);
begin

end;

procedure TSprite.SetX(const Value: Single);
begin

end;

procedure TSprite.SetY(const Value: Single);
begin

end;

procedure TSprite.SetZ(const Value: Integer);
begin

end;

constructor TSprite.Create(const AParent: TSprite);
begin
   inherited Create;
  FParent := AParent;
  if FParent <> nil then
  begin
    FParent.Add(Self);
    if FParent is TSpriteEngine then
      FEngine := TSpriteEngine(FParent)
    else
      FEngine := FParent.Engine;
    Inc(FEngine.FAllCount);
  end;
  FX := 200;
  FY := 200;
  FZ := 0;
  if Z = 0 then
    Z := 1;
  FWidth := 64;
  FHeight := 64;
  FName := '';
  FZ := 0;
  FDoCollision := False;
  FMoved := True;
  FBlendingEffect := TBlendingEffect.BLEND_ALPHA;
  FVisible := True;
  TruncMove := True;
  FTag := 0;
  FCollideMode := cmCircle;
end;

destructor TSprite.Destroy;
begin
  inherited Destroy;
end;

procedure TSprite.Assign(const Value: TSprite);
begin

end;

procedure TSprite.Clear;
begin

end;

procedure TSprite.Move(const MoveCount: Single);
begin

end;

procedure TSprite.SetPos(X, Y: Single);
begin

end;

procedure TSprite.SetPos(X, Y: Single; Z: Integer);
begin

end;

procedure TSprite.Collision(const Other: TSprite);
begin

end;

procedure TSprite.Collision;
begin

end;

procedure TSprite.Dead;
begin

end;





{ TAnimations }

function TAnimations.GetItem(Index: Integer): TFrameRec;
begin
  if (Index >= 0) and (Index < Length(FrameData)) then Result := FrameData[Index];
end;

function TAnimations.GetItemCount(): Integer;
begin
  Result := Length(FrameData);
end;

procedure TAnimations.InitSearchObjects();
var
  I: Integer;
begin
  if (Length(FrameData) <> Length(SearchObjects)) then SetLength(SearchObjects, Length(FrameData));
  for I := 0 to Length(FrameData) - 1 do SearchObjects[I] := I;
end;

procedure TAnimations.SwapSearchObjects(Index1, Index2: Integer);
var
  Aux: Integer;
begin
  Aux := SearchObjects[Index1];
  SearchObjects[Index1] := SearchObjects[Index2];
  SearchObjects[Index2] := Aux;
end;

function TAnimations.CompareSearchObjects(Obj1, Obj2: TFrameRec): Integer;
begin
  Result := CompareText(Obj1.FrameName, Obj2.FrameName);
end;

function TAnimations.SplitSearchObjects(Start, Stop: Integer): Integer;
var
  Left, Right: Integer;
  Pivot: TFrameRec;
begin
  Left := Start + 1;
  Right := Stop;
  Pivot := FrameData[SearchObjects[Start]];
  while (Left <= Right) do
  begin
    while (Left <= Stop) and (CompareSearchObjects(FrameData[SearchObjects[Left]], Pivot) < 0) do
      Inc(Left);
    while (Right > Start) and (CompareSearchObjects(FrameData[SearchObjects[Right]], Pivot) >= 0) do
      Dec(Right);
    if (Left < Right) then SwapSearchObjects(Left, Right);
  end;
  SwapSearchObjects(Start, Right);
  Result := Right;
end;

procedure TAnimations.SortSearchObjects(Start, Stop: Integer);
var
  SplitPt: Integer;
begin
  if (Start < Stop) then
  begin
    SplitPt := SplitSearchObjects(Start, Stop);
    SortSearchObjects(Start, SplitPt - 1);
    SortSearchObjects(SplitPt + 1, Stop);
  end;
end;

procedure TAnimations.UpdateSearchObjects();
begin
  InitSearchObjects();
  SortSearchObjects(0, Length(SearchObjects) - 1);
  SearchDirty := False;
end;

function TAnimations.GetFrame(const Name: string): TFrameRec;
var
  Index: Integer;
begin
  Index := IndexOf(Name);
  if (Index <> -1) then
    Result := FrameData[Index];
end;

function TAnimations.IndexOf(const Name: string): Integer;
var
  Lo, Hi, Mid: Integer;
begin
  if (SearchDirty) then
    UpdateSearchObjects();
  Result := -1;
  Lo := 0;
  Hi := Length(SearchObjects) - 1;
  while (Lo <= Hi) do
  begin
    Mid := (Lo + Hi) div 2;
    if (CompareText(FrameData[SearchObjects[Mid]].FrameName, Name) = 0) then
    begin
      Result := SearchObjects[Mid];
      Break;
    end;
    if (CompareText(FrameData[SearchObjects[Mid]].FrameName, Name) > 0) then
      Hi := Mid - 1
    else
      Lo := Mid + 1;
  end;
end;

procedure TAnimations.Remove(Index: Integer);
var
  I: Integer;
begin
  if (Index < 0) or (Index >= Length(FrameData)) then
    Exit;
  for I := Index to Length(FrameData) - 2 do
    FrameData[I] := FrameData[I + 1];
  SetLength(FrameData, Length(FrameData) - 1);
  SearchDirty := True;
end;

procedure TAnimations.AddFrames(FrameName: string; Frames: array of Cardinal);
var
  I, Index: Integer;
begin
  Index := Length(FrameData);
  SetLength(FrameData, Index + 1);
  FrameData[Index].FrameName := FrameName;
  SetLength(FrameData[Index].Frames, High(Frames) + 1);
  for I := 0 to High(Frames) do
    FrameData[Index].Frames[I] := Frames[I];
  SearchDirty := True;
end;

procedure TAnimations.RemoveAll();
begin
  SetLength(FrameData, 0);
  SearchDirty := True;
end;

procedure TAnimations.MarkSearchDirty();
begin
  SearchDirty := True;
end;

constructor TAnimations.Create();
begin
 SearchDirty := False;
end;

destructor TAnimations.Destroy();
begin
  RemoveAll();
  inherited;
end;

end.


