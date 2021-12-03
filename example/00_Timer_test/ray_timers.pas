{ Original code Copyright (c) 2012 Andrey Kemka }
{ Mod for Raylib 2021 Gunko Vadim }

unit ray_timers;

//{$I zgl_config.cfg}
{$mode Delphi}{$H+}

interface
{$IFDEF LINUX}
uses UnixType;
{$ENDIF}
{$IFDEF WINDOWS}
uses Windows;
{$ENDIF}

type
  zglPTimer = ^zglTTimer;
  zglTTimer = record
    Active     : Boolean;
    Custom     : Boolean;
    UserData   : Pointer;
    Interval   : LongWord;
    LastTick   : Double;
    OnTimer    : procedure;
    OnTimerEx  : procedure( Timer : zglPTimer );
    prev, next : zglPTimer;
end;

type
  zglPTimerManager = ^zglTTimerManager;
  zglTTimerManager = record
    Count : Integer;
    First : zglTTimer;
end;

function  timer_Add( OnTimer : Pointer; Interval : LongWord; UseSenderForCallback : Boolean = FALSE; UserData : Pointer = nil ) : zglPTimer;
procedure timer_Del( var Timer : zglPTimer );

procedure timer_MainLoop;
function  timer_GetTicks : Double;
procedure timer_Reset;

var
  managerTimer  : zglTTimerManager;
  canKillTimers : Boolean = TRUE;
  appdt : Double;

implementation
//uses
 // zgl_application,
 // zgl_main;

{$IFDEF LINUX}
function fpGetTimeOfDay( val : PTimeVal; tzp : Pointer ) : Integer; cdecl; external 'libc' name 'gettimeofday';
{$ENDIF}
{$IFDEF DARWIN}
type
  mach_timebase_info_t = record
    numer : LongWord;
    denom : LongWord;
  end;

  function mach_timebase_info( var info : mach_timebase_info_t ) : Integer; cdecl; external 'libc';
  function mach_absolute_time : QWORD; cdecl; external 'libc';
{$ENDIF}

var
  timersToKill  : Word = 0;
  aTimersToKill : array[ 0..1023 ] of zglPTimer;

  {$IFDEF LINUX}
  timerTimeVal : TimeVal;
  {$ENDIF}
  {$IFDEF WINDOWS}
  timerFrequency : Int64;
  timerFreq      : Single;
  {$ENDIF}
  {$IFDEF DARWIN}
  timerTimebaseInfo : mach_timebase_info_t;
  {$ENDIF}
  timerStart : Double;

  procedure zgl_GetMem( out Mem : Pointer; Size : LongWord );
    begin
  if Size > 0 Then
    begin
      GetMem( Mem, Size );
      FillChar( Mem^, Size, 0 );
    end else
      Mem := nil;
  end;

function timer_Add( OnTimer : Pointer; Interval : LongWord; UseSenderForCallback : Boolean = FALSE; UserData : Pointer = nil ) : zglPTimer;
begin
  Result := @managerTimer.First;

  while Assigned( Result^.next) do
    Result := Result^.next;

  zgl_GetMem( Pointer( Result.next ), SizeOf( zglTTimer ) );
  Result.next.Active    := TRUE;
  Result.next.Custom    := UseSenderForCallback;
  Result.next.UserData  := UserData;
  Result.next.Interval  := Interval;
  if UseSenderForCallback Then
    Result.next.OnTimerEx := OnTimer
  else
    Result.next.OnTimer := OnTimer;
  Result.next.LastTick  := timer_GetTicks();
  Result.next.prev      := Result;
  Result.next.next      := nil;
  Result := Result.next;
  INC( managerTimer.Count );
end;

procedure timer_Del( var Timer : zglPTimer );
begin
  if not Assigned( Timer ) Then exit;

  if not canKillTimers Then
    begin
      INC( timersToKill );
      aTimersToKill[ timersToKill ] := Timer;
      Timer := nil;
      exit;
    end;

  if Assigned( Timer.Prev ) Then
    Timer.prev.next := Timer.next;
  if Assigned( Timer.next ) Then
    Timer.next.prev := Timer.prev;
  FreeMem( Timer );
  Timer := nil;

  DEC( managerTimer.Count );
end;

procedure timer_MainLoop;
  var
    i     : Integer;
    t     : Double;
    timer : zglPTimer;
begin
  canKillTimers := FALSE;

  timer := @managerTimer.First;
  if timer <> nil Then
    for i := 0 to managerTimer.Count do
      begin
        if timer.Active then
          begin
            t := timer_GetTicks();
            while t >= timer.LastTick + timer.Interval do
              begin
                timer.LastTick := timer.LastTick + timer.Interval;
                if timer.Custom Then
                  timer.OnTimerEx( timer )
                else
                  timer.OnTimer();
                if t < timer_GetTicks() - timer.Interval Then
                  break
                else
                  t := timer_GetTicks();
              end;
          end else timer.LastTick := timer_GetTicks();

        timer := timer.next;
      end;

  canKillTimers := TRUE;
  for i := 1 to timersToKill do
    timer_Del( aTimersToKill[ i ] );
  timersToKill  := 0;
end;

function timer_GetTicks : Double;
  {$IFDEF WINDOWS}
  var
    t : int64;
    m : LongWord;
  {$ENDIF}
begin
{$IFDEF LINUX}
  fpGetTimeOfDay( @timerTimeVal, nil );
  {$Q-}
  // FIXME: почему-то overflow вылетает с флагом -Co
  Result := timerTimeVal.tv_sec * 1000 + timerTimeVal.tv_usec / 1000 - timerStart;
  {$Q+}
{$ENDIF}
{$IFDEF WINDOWS}
  m := SetThreadAffinityMask( GetCurrentThread(), 1 );
  QueryPerformanceCounter( t );
  Result := 1000 * t * timerFreq - timerStart;
  SetThreadAffinityMask( GetCurrentThread(), m );
{$ENDIF}
{$IFDEF DARWIN}
  Result := mach_absolute_time() * timerTimebaseInfo.numer / timerTimebaseInfo.denom / 1000000 - timerStart;
{$ENDIF}
end;

procedure timer_Reset;
  var
    currTimer : zglPTimer;
begin
  appdt := timer_GetTicks();
  currTimer := @managerTimer.First;
  while Assigned( currTimer ) do
    begin
      currTimer.LastTick := timer_GetTicks();
      currTimer := currTimer.next;
    end;
end;

initialization
{$IFDEF WINDOWS}
  SetThreadAffinityMask( GetCurrentThread(), 1 );
  QueryPerformanceFrequency( timerFrequency );
  timerFreq := 1 / timerFrequency;
{$ENDIF}
{$IFDEF DARWIN}
  mach_timebase_info( timerTimebaseInfo );
{$ENDIF}
  timerStart := timer_GetTicks();

end.
