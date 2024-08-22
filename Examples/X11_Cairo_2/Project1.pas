program Project1;

uses
  unixtype,
  ctypes,
  xlib,
  xutil,
  keysym,
  x,
  cairo218,
  cairo_xlib;

type

  TMyWin = class(TObject)
  private
    dis: PDisplay;
    scr: cint;
    win: TWindow;
    widht, Height: cuint;
    wm_delete_window: TAtom;

    cr_surface: Pcairo_surface_t;
    cr: Pcairo_t;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw;
    procedure Run;
  end;

  constructor TMyWin.Create;
  begin
    inherited Create;

    dis := XOpenDisplay(nil);
    if dis = nil then begin
      WriteLn('Kann nicht das Display öffnen');
      Halt(1);
    end;
    scr := DefaultScreen(dis);

    widht := 640 * 2;
    Height := 480 * 2;

    win := XCreateSimpleWindow(dis, RootWindow(dis, scr), 10, 10, widht, Height, 1, BlackPixel(dis, scr), WhitePixel(dis, scr));

    XSelectInput(dis, win, KeyPressMask or ButtonPressMask or ExposureMask);
    XStoreName(dis, win, 'X11-Cairo');
    XMapWindow(dis, win);

    wm_delete_window := XInternAtom(dis, 'WM_DELETE_WINDOW', False);
    XSetWMProtocols(dis, win, @wm_delete_window, 1);

    cr_surface := cairo_xlib_surface_create(dis, win, DefaultVisual(dis, scr), widht, Height);
    cairo_xlib_surface_set_size(cr_surface, widht, Height);
    cr := cairo_create(cr_surface);
  end;

  destructor TMyWin.Destroy;
  begin
    cairo_destroy(cr);
    cairo_surface_destroy(cr_surface);

    XDestroyWindow(dis, win);
    XCloseDisplay(dis);

    inherited Destroy;
  end;

  procedure TMyWin.Draw;
  var
    i: integer;
  begin
    for i := 1 to 100000 do begin
      cairo_set_source_rgba(cr, random, Random, Random, 1.0);
      cairo_rectangle(cr, Random(widht)-50, Random(Height)-50, Random(100), Random(100));
      cairo_fill(cr);
      cairo_stroke(cr);
    end;
  end;

  procedure TMyWin.Run;
  var
    Event: TXEvent;
    quit: boolean = False;
  begin
    while not quit do begin
      XNextEvent(dis, @Event);
      WriteLn('Event: ', Event._type);

      case Event._type of
        KeyPress: begin
          case XLookupKeysym(@Event.xkey, 0) of
            XK_Escape: begin
              quit := True;
            end;
          end;
        end;
        Expose: begin
          Draw;
        end;
        ClientMessage: begin
          if (Event.xclient.Data.l[0] = wm_delete_window) then begin
            WriteLn('[X] wurde gedrückt');
            quit := True;
          end;
        end;
      end;
    end;
  end;

var
  MyWindows: TMyWin;

begin
  MyWindows := TMyWin.Create;
  MyWindows.Run;
  MyWindows.Free;
end.
//code-
