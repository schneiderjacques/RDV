function my_tests()
% calcul des descripteurs de Fourier de la base de données
img_db_path = './db/';
img_db_list = glob([img_db_path, '*.gif']);
img_db = cell(1);
label_db = cell(1);
fd_db = cell(1);
for im = 1:numel(img_db_list);
    img_db{im} = logical(imread(img_db_list{im}));
    label_db{im} = get_label(img_db_list{im});
    disp(label_db{im}); 
    [fd_db{im},~,~,~] = compute_fd(img_db{im});
end

% importation des images de requête dans une liste
img_path = './dbq/';
img_list = glob([img_path, '*.gif']);
t=tic()

% pour chaque image de la liste...
for im = 1:numel(img_list)
   
    % calcul du descripteur de Fourier de l'image
    img = logical(imread(img_list{im}));
    [fd,r,m,poly] = compute_fd(img);
       
    % calcul et tri des scores de distance aux descripteurs de la base
    for i = 1:length(fd_db)
        scores(i) = norm(fd-fd_db{i});
    end
    [scores, I] = sort(scores);
       
    % affichage des résultats    
    close all;
    figure(1);
    top = 5; % taille du top-rank affiché
    subplot(2,top,1);
    imshow(img); hold on;
    plot(m(1),m(2),'+b'); % affichage du barycentre
    plot(poly(:,1),poly(:,2),'v-g','MarkerSize',1,'LineWidth',1); % affichage du contour calculé
    subplot(2,top,2:top);
    plot(r); % affichage du profil de forme
    for i = 1:top
        subplot(2,top,top+i);
        imshow(img_db{I(i)}); % affichage des top plus proches images
    end
    drawnow();
    waitforbuttonpress();
end
end

function [fd, r, m, poly] = compute_fd(img)
N = 50; % à modifier !!!
M = 100; % à modifier !!!
h = size(img, 1);
w = size(img, 2);

[y, x] = find(img > 0);
n = length(x);
m_x = sum(x) / n;
m_y = sum(y) / n;
m = [m_x, m_y];

t = linspace(0, 2 * pi, N);
R = min(h, w)/5;
poly = [m(1) + R * cos(t'), m(2) + R * sin(t')]; % à modifier !!!
r = zeros(1, N);

for i = 1:N
    % Coordonnées du point p(t) sur le rayon d'angle t passant par le barycentre m
    x = round(m_x + R * cos(t(i)));
    y = round(m_y + R * sin(t(i)));

    % Tant que le pixel est blanc, avancer sur le rayon
    while x > 0 && y > 0 && x <= w && y <= h && img(y, x) == 1
        x = round(x + cos(t(i)));
        y = round(y + sin(t(i)));
    end

    % Coordonnées du dernier pixel blanc rencontré, qui correspond à p(t)
    p = [x - cos(t(i)), y - sin(t(i))];

    % Distance euclidienne entre le barycentre m et le point p(t)
    r(i) = norm(m - p);

    % Recalculer les coordonnées du polygone pour suivre le contour de l'objet
    poly(i,:) = [x,y];
end

% Calcul du descripteur de Fourier
R = fft(r);
R_abs = abs(R);
R_abs_norm = R_abs / R_abs(1);
fd = R_abs_norm(2:min(M+1, length(R_abs_norm)));

end
