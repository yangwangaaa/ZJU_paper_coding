clc;  %%%利用静态声源辅助实现单个未知节点定位WLS
clear all
format short
close all

%% 设定全局变量
global SIGMA
global M
%% 设定基本的参数，比如蒙特卡洛的个数，DOA误差范围，声源个数等参数
M =2000;                         %Monte Caro times
%Beacon=[45,55;30,70;95,50;100,50;85,35;40,40;50,15;60,40;20,30;75,60];
%Beacon=round(rand(5,2)*100);
%Unodes=[100,90,pi/3];             %未知节点的位置信息Unodes=[170,120,pi/3]; 
R=300;                            %感知半径
threshold =150;
err=10;
%% 在不同声源数目下进行定位
z=0;
Unodes=[80,90,pi/4];
 for SIGMA = 1: err
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
                [P_Bias,H_Bias,HP] = TRI_TWO(SBStore,DOA,Unodes(1:2),Unodes(3));%使用Psedo-Linear Least Squares.
                if  P_Bias< threshold %&& H_Bias<threshold
                    num= num + 1;
                    PLS_PBias(num,:) =HP;  %存储结果，运行次数num
                    %PE_Pbias(num,:)=PLE_PBias;
%                     PLS_HBias(num) = H_Bias;
                end
            end
            DOA=[];
            SBStore=[];
        end
        z=z+1;
        PLEXY=mean(PLS_PBias);
        PBIAS(z)=sqrt((Unodes(1)-PLEXY(1))^2+(Unodes(2)-PLEXY(2))^2);
        HBIAS(z)=abs(PLEXY(3)-Unodes(3))*180/pi;
        display('------the programming is running now-----');
%         PBIAS(z) = mean(PLS_PBias); %位置误差
%         HBIAS(z)= mean(PLS_HBias);
        PLS_PBias=[];
        PLS_HBias=[];
 end
Sigma=1: err;
%% 数据存储
xlswrite('TR_PE',PBIAS);%位置误差保存
xlswrite('TR_HE',HBIAS);%角度误差保存

%% 图形显示2  节点方差
figure(1)
subplot(2,1,1)
plot(Sigma,PBIAS,'b*--','linewidth',1.5)
set(gca,'Fontsize',14);
xlabel('AOA Noise Standard Deviation (degree)');
ylabel('Location Error (m)');
grid on 

subplot(2,1,2)
plot(Sigma,HBIAS,'b*--','linewidth',1.5)
set(gca,'Fontsize',14)
xlabel('AOA Noise Standard Deviation (degree)');
ylabel('Orienation Error (degree)');
grid on 
