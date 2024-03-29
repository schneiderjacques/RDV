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
N = 500; % à modifier !!!
M = 300; % à modifier !!!
h = size(img, 1);
w = size(img, 2);

[y, x] = find(img > 0);
n = length(x);
m_x = sum(x) / n;
m_y = sum(y) / n;
m = [m_x, m_y];

t = linspace(0, 2 * pi, N);
%R = min(h, w) / 2;
%poly = [m(1) + R * cos(t'), m(2) + R * sin(t')]; % à modifier !!!
poly = zeros(N,2);
r = zeros(1, N);
%Pour N valeurs d’un angle t variant de 0 à 2π (le choix de N est laissé à votre appréciation),
 %calculer l’intersection p(t) entre le contour de l’objet et le rayon partant de m formant un
 %angle t avec l’axe horizontal de l’image. Soit r(t) la distance euclidienne entre m et p(t).
 %Nous appellerons profil de la forme la courbe r(t)
for i = 1:N
    %Une méthode simple pour calculer les points d’intersection p(t) sans avoir à détecter le contour
    %de l’objet au préalable est la suivante :
    %partir du barycentre m,
    %avancer le long du rayon d’angle t tant que le pixel est blanc.
    %Le dernier pixel blanc rencontré le long du rayon correspond à p(t)

    % calcul de p(t)
    p = m;
    while (round(p(1)) > 0 && round(p(1)) <= w && round(p(2)) > 0 && round(p(2)) <= h && img(round(p(2)), round(p(1))) == 1)
        p = p + [cos(t(i)), sin(t(i))];
    end
    poly(i, :) = p;
    r(i) = norm(p - m);

end

% Calculer la TF R(f) de r(t). Le descripteur de Fourier que nous utiliserons pour calculer les
  %scores est le vecteur f d formé par les M premiers coefficients du vecteur |R(f)|/|R(0)|. Le
  %choix de M est également laissé à votre appréciation.
fd = fft(r);
fd = abs(fd(1:M)) / abs(fd(1));

end
