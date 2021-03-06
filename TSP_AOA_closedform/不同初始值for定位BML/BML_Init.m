clc;  %%%利用静态声源辅助实现单个未知节点定位WLS
clear all
format long
close all

%% 设定全局变量
global SIGMA
global M
%% 设定基本的参数，比如蒙特卡洛的个数，DOA误差范围，声源个数等参数
M = 2000;                         %Monte Caro times
%Beacon=[45,55;30,70;95,50;100,50;85,35;40,40;50,15;60,40;20,30;75,60];
%Beacon=round(rand(10,2)*100);
%Bl=length(Beacon(:,1));          %信标个数 Beacon=[10,20,pi/3;0,160,pi/6;170,190,pi/5;130,10,pi/4;60,100,pi/5];
Unodes=[100,100,pi/3];            %未知节点的位置信息Unodes=[170,120,pi/3]; 
R=300;                            %感知半径
threshold = 2000;
err=10;
%% 在不同声源数目下进行定位
z=0;
 for SIGMA = 1: 1 : err
        num=0;
        nm=0;
        for i=1:M    
            kk=1;
            ei=0;
            pi1=0;
            SPbias=[];
            Beacon=round(rand(10,2)*100);
%             node=round(rand(1,2)*100);
%             Hdr=round(rand(1,1)*100*pi/2)/100;
%             Unodes=[node,Hdr];
 %% %%%%%%%%%%% 未知节点对声源和信标节点的DOA测量值%%%%%%%%%%%%%%%%%%%%
           S_Bcon=Beacon(:,1:2); 
            ku=0;
            for ib=1:length(S_Bcon(:,1))
                 BL=S_Bcon(ib,:);           %已定位的声源和信标
                 if sqrt((BL(1)-Unodes(1))^2+(BL(2)-Unodes(2))^2)<=R                       
                       ku=ku+1;
                       DOA(ku)= Current_Radian(BL,Unodes);   % 测得的带有噪声DOA值
                       SBStore(ku,:)=BL;    %声源估计位置存储
                 end
            end
            if ku>=3
  %% 用已知的声源对未知节点进行定位
                [UT,PLE_PBias, PLE_HBias] = PLS(SBStore,DOA,Unodes(1:2),Unodes(3));
                [U,OV,P_Bias, H_Bias] = BCPLS(SBStore,DOA,Unodes(1:2),Unodes(3));%使用Psedo-Linear Least Squares.
                [MP1, MH1]=BMLF(SBStore,DOA,Unodes(1:2),Unodes(3),OV);
                [MP2, MH2]=BML2(SBStore,DOA,Unodes(1:2),Unodes(3));
                %[PLE_WP, PLE_WH]=BML3(SBStore,DOA,Unodes(1:2),Unodes(3));
                [PLE_WP, PLE_WH] = WIV2(SBStore,DOA,Unodes(1:2),Unodes(3),UT);
                [WP_Bias, WH_Bias] = WIV(SBStore,DOA,Unodes(1:2),Unodes(3),U);  %BCPLE_WIV
                if  MP1< threshold && MP2< threshold && PLE_WP< threshold && WP_Bias<150
                    num= num + 1;
                    ML1_PBias(num) = MP1;
                    ML1_HBias(num) = MH1; 
                    ML2_PBias(num) = MP2;
                    ML2_HBias(num) = MH2; 
                    ML3_PBias(num) = PLE_WP;
                    ML3_HBias(num) = PLE_WH; 
                    WIV_Pbias(num)= WP_Bias;
                    WIV_Hbias(num)= WH_Bias;
                end
            end
            DOA=[];
            SBStore=[];
        end
        display('------the programming is running now-----');
        z=z+1;
        M1PBIAS(z) =mean(ML1_PBias); %位置误差
        M1HBIAS(z)= mean(ML1_HBias);
        M2PBIAS(z) =mean(ML2_PBias); %位置误差
        M2HBIAS(z)= mean(ML2_HBias);
        M3PBIAS(z) =mean(ML3_PBias); %位置误差
        M3HBIAS(z)= mean(ML3_HBias);
        WIV_PB(z)=mean(WIV_Pbias);
        WIV_HB(z)=mean(WIV_Hbias);
        ML1_PBias=[];
        ML1_HBias=[];
        ML2_PBias=[];
        ML2_HBias=[];
        ML3_PBias=[];
        ML3_HBias=[];
        WIV_Pbias=[];
        WIV_Hbias=[];
 end

Sigma=1: 1 : err;
%% 数据存储
xlswrite('M1PBIAS',M1PBIAS);%ML位置误差保存
xlswrite('M1HBIAS',M1PBIAS);%ML角度误差保存
xlswrite('M2PBIAS',M2PBIAS);%ML位置误差保存
xlswrite('M2HBIAS',M2PBIAS);%ML角度误差保存
xlswrite('WIVPBIAS',WIV_PB);%ML位置误差保存
xlswrite('WIVBIAS',WIV_HB);%ML角度误差保存
xlswrite('AVPLEWIV_P',M3PBIAS);%ML位置误差保存
xlswrite('AVPLEWIV_H',M3PBIAS);%ML角度误差保存


%% 图形显示2  节点方差
figure(1)
subplot(2,1,1)
plot(Sigma,M1PBIAS,'ks--', Sigma, M2PBIAS,'bv--', Sigma, M3PBIAS,'ro--',Sigma, WIV_PB,'g+--','linewidth',1.5)
set(gca,'Fontsize',13);
h=legend('ML1','ML2','AVPLE-WIV','BCAVPLE-WIV');

set(h,'Fontsize',12)
xlabel('AOA Noise Standard Deviation (degrees)');
ylabel('Location Error (m)');
set(gca,'XTick',1:10);
axis([1 10 0 150])
grid on 

subplot(2,1,2)
plot(Sigma,M1HBIAS,'ks--', Sigma, M2HBIAS,'bv--', Sigma, M3HBIAS,'ro--',Sigma, WIV_HB,'g+--','linewidth',1.5)
set(gca,'Fontsize',13)
h=legend('ML1','ML2','AVPLE-WIV','BCAVPLE-WIV');
set(h,'Fontsize',12)
xlabel('AOA Noise Standard Deviation (degrees)');
ylabel('Orienation Error (degrees)');
set(gca,'XTick',1:10);
axis([1 10 0 200])
%axis([1 10 0 80])
grid on 

% figure(1)
% subplot(2,1,1)
% plot(Sigma,M1PBIAS,'ks--', Sigma, M2PBIAS,'bv--',Sigma, WIV_PB,'g+--','linewidth',1.5)
% set(gca,'Fontsize',13);
% h=legend('ML1','ML2','BCAVPLE-WIV');
% set(h,'Fontsize',12)
% xlabel('Bearing Noise Standard Deviation (degrees)');
% ylabel('Location Error (m)');
% set(gca,'XTick',1:10);
% axis([1 10 0 150])
% %axis([1 10 0 80])
% grid on 
% 
% subplot(2,1,2)
% plot(Sigma,M1HBIAS,'rs--', Sigma, M2HBIAS,'bv--', Sigma, WIV_HB,'g+--','linewidth',1.5)
% set(gca,'Fontsize',13)
% h=legend('ML1','ML2','BCAVPLE-WIV');
% set(h,'Fontsize',12)
% xlabel('Bearing Noise Standard Deviation (degrees)');
% ylabel('Orienation Error (degrees)');
% set(gca,'XTick',1:10);
% axis([1 10 0 150])
% grid on 
