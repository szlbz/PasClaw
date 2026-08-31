{
  PasClaw - Ultra-lightweight personal AI agent (Lazarus/FPC version)
  Converted from Delphi project for Lazarus IDE compatibility.
  Original: https://github.com/FMXExpress/PasClaw
  License: MIT

  Build with Lazarus:
    Open PasClaw.lpi in Lazarus IDE and build (Ctrl+F9)
  Or use lazbuild from command line:
    lazbuild PasClaw.lpi
}

program PasClaw;

{$MODE DELPHI}
{$H+}
{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}
  cthreads,            { FPC/Linux: pull in pthreads so Indy can use TThread }
  cmem,
  {$ENDIF}
  Interfaces,
  SysUtils,
  PasClaw.CliUI,
  PasClaw.Logger,
  PasClaw.Config,
  PasClaw.Cmd.Root, indylaz;

function IsStdioMCPInvocation: Boolean;
{ When invoked as `pasclaw mcp stdio`, stdout MUST stay clean JSON-RPC }
var
  i: Integer;
  Cmd, Next: string;
begin
  Result := False;
  if ParamCount < 1 then Exit;
  Cmd := ParamStr(1);
  if Cmd = '__tool' then Exit(True);
  if Cmd <> 'mcp' then Exit;
  for i := 2 to ParamCount do
  begin
    Next := ParamStr(i);
    if (Next = '') or (Next[1] = '-') then Continue;
    Exit(Next = 'stdio');
  end;
end;

function IsQuietInvocation: Boolean;
{ Suppress the banner whenever the user passed --quiet or -q }
var
  i: Integer;
  Arg: string;
begin
  Result := False;
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if (Arg = '--quiet') or (Arg = '-q') then Exit(True);
  end;
end;

var
  ExitCode_: Integer;
begin
  { Detect color support before any output so the banner respects NO_COLOR. }
  CliUI_Init(EarlyColorDisabled);

  if not (IsStdioMCPInvocation or IsQuietInvocation) then
    PrintBanner;
  if IsQuietInvocation then
    SetLogLevel(llError);
  ApplyTimezoneFromEnv;

  ExitCode_ := RunRootCommand;
  if ExitCode_ <> 0 then
    Halt(ExitCode_);
end.
