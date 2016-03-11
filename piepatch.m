function h = piepatch(data, x, y, r, varargin)
%PIEPATCH Creates a pie chart at a given location
%
% h = piepatch(data, x, y, r);
% h = piepatch(data, x, y, r, p1, v1, ...)
%
% Creates a pie chart plotted at a given location within the specified
% axis.  Unlike pie, does not make any other modifications to that axis.
%
% Input variables:
%
%   data:   vector of input data
%
%   x:      x coordinate for center of pie
%
%   y:      y coordinate for center of pie
%
%   r:      radius of pie
%
% Optional input variables:
%
%   npt:    number of points used to construct full circle [50]
%
%   sum:    value equal to whole pie.  If empty, will be equal to
%           sum(data). []
%
%   lblpos: position along radial line where text labels will be centered.
%           0 is the center of the pie, 1 is the outer edge (labels are
%           oriented radially). [0.5]
%
%   lbl:    length(data) x 1 cell array of strings, labels for each pie
%           slice [{'1'; '2'; '3'; ... 'n'}]
%
%   axis:   handle of axis to plot to [gca]
%
%   label:  if true, add text labels [true]

% Copyright 2012 Kelly Kearney

data = data(:);
ndata = length(data);

Opt.npt = 50; % # points used in total circle
Opt.sum = sum(data);
Opt.lblpos = 0.5;
Opt.lbl = cellstr(num2str((1:ndata)'));
Opt.axis = gca;
Opt.label = true;

Opt = parsepv(Opt, varargin);

dtheta = 2*pi/Opt.npt;

% Caculate pie slice coords

frac = data./Opt.sum;
cfrac = cumsum([0; frac]);

% Major and minor axes based on data aspect ratios

axunit = get(Opt.axis, 'unit');
set(Opt.axis, 'unit', 'pixels');
pos = plotboxpos(Opt.axis);
lim = get(Opt.axis, {'xlim', 'ylim'});
yratio = (diff(lim{2})/pos(4))./(diff(lim{1})/pos(3));
set(Opt.axis, 'unit', axunit);
    
rx = r;
ry = r .* yratio;

% Plot pie

if ndata == 0
    h = struct('p',[],'txt', []);
end
for id = 1:ndata
    n = max(ceil((cfrac(id+1) - cfrac(id))*2*pi/dtheta), 2);
    theta = linspace(cfrac(id)*2*pi, cfrac(id+1)*2*pi, n);
    
    xp = x + rx .* cos(theta);
    yp = y + ry .* sin(theta);
    xp = [x xp x];
    yp = [y yp y];
    
    h.p(id) = patch(xp, yp, 'w', 'parent', Opt.axis);
    
    thetamid = cfrac(id)*pi + cfrac(id+1)*pi;
    xt = x + rx .* Opt.lblpos .* cos(thetamid);
    yt = y + ry .* Opt.lblpos .* sin(thetamid);

    rot = 180/pi * thetamid;
    
    if rot > 90 && rot < 270
        rot = rot + 180;
    end
    
    if Opt.label
        h.txt(id) = text(xt, yt, Opt.lbl{id}, 'horiz', 'center', 'rotation', rot, 'parent', Opt.axis);
    end
end
