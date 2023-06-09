//+------------------------------------------------------------------+
//|                                           ArbitragemDayTrade.mq5 |
//|                                           Anderson Campos Pavani |
//|                   https://www.andersonpavani.com.br/market/robos |
//+------------------------------------------------------------------+

#property copyright "Anderson Campos Pavani"
#property link "https://www.andersonpavani.com.br/market/robos"
#property version "1.00"


//Definições
//#define VERSAO_BACKTESTE
#define dNumeroMagico 7000


//Includes
#include "..\Lib\Par.mqh"
#include "..\Lib\Robo.mqh"
#include "Interface.mqh"


//Parametros de Entrada
input group "Parametros de Operação"

#ifdef VERSAO_BACKTESTE
  input int iNumeroMagico = 1;
  input string iAtivoCompra = "PETR3"; //Ativo de Compra
  input string iAtivoVenda = "PETR4"; //Ativo de Venda
  input int iPeriodosMediaMovel = 40; //Períodos Média Móvel
  input double iDesviosEntrada = 2; //Desvios para Entrada
  input double iDesviosSaida = 0.5; //Desvios para Saída
#else
  input string iStringPares1 = "1,BBDC3,BBDC4,20,2,0.5;2,BRAP3,BRAP4,20,2,0.5;3,CMIG3,CMIG4,20,2,0.5;4,CPLE11,CPLE3,20,2,0.5;5,CPLE11,CPLE6,20,2,0.5;6,CPLE3,CPLE6,20,2,0.5;"; //String de Configuração dos Pares 1
  input string iStringPares2 = "7,ELET3,ELET6,20,2,0.5;8,GGBR3,GGBR4,20,2,0.5;9,GOAU3,GOAU4,20,2,0.5;10,ITSA3,ITSA4,20,2,0.5;11,ITUB3,ITUB4,20,2,0.5;12,KLBN11,KLBN4,20,2,0.5;"; //String de Configuração dos Pares 2
  input string iStringPares3 = "13,PETR3,PETR4,20,2,0.5;14,SAPR11,SAPR4,20,2,0.5;15,GGBR4,GOAU4,20,2,0.5;16,ITSA4,ITUB4,20,2,0.5"; //String de Configuração dos Pares 3
#endif

input double iCapitalAtual = 20000; //Capital Atual
input int iOperacoesSimultaneas = 3; //Quantidade de Operações Simultâneas
input double iAlavancagem = 10; //Alavancagem
input double iPercentualCapital = 90; //Percentual do Capital a ser utilizado
input int iFatorMultiplicadorBook = 2; //Fator Multiplicador para Análise do Book
input group "Janela de Operação"
input bool iIniciarAposLeilao = true; //Iniciar Operações após Leilão
input EnumHorarios iHorarioInicialEntrada = h1800; //Horário Inicial para Entradas
input EnumHorarios iHorarioFinalEntrada = h1400; //Horário Final para Entradas
input EnumHorarios iHorarioEncerramentoOperacoes = h1635; //Horário para Encerramento das Operações
input group "Parametros da Interface"
input bool iExibirInterface = true; //Exibir Interface
input int iQuantidadeColunas = 7; //Quantidade de Colunas


//Variáveis Globais
bool ChecarLiquidez;


bool CarregarConfiguracao() {
  #ifdef VERSAO_BACKTESTE
    CPar *Par = new CPar();
    
    Par.NumeroMagico = iNumeroMagico;
    Par.AtivoCompra = iAtivoCompra;
    Par.AtivoVenda = iAtivoVenda;
    Par.PeriodosMediaMovel = iPeriodosMediaMovel;
    Par.DesviosPadraoEntrada = iDesviosEntrada;
    Par.DesviosPadraoSaida = iDesviosSaida;
    
    Pares.Add(Par);
  #else
    string StringPares = iStringPares1 + iStringPares2 + iStringPares3;
    
    string x[];
    string xx[];
    
    StringSplit(StringPares, ';', x);
    
    if (ArraySize(x) < 1)
      return false;
    
    for (int i = 0; i < ArraySize(x); i++) {
      StringSplit(x[i], ',', xx);
      
      if (ArraySize(xx) != 6)
        return false;
      
      CPar *Par = new CPar();
      
      Par.NumeroMagico = (int)StringToInteger(xx[0]);
      Par.AtivoCompra = xx[1];
      Par.AtivoVenda = xx[2];
      Par.PeriodosMediaMovel = (int)StringToInteger(xx[3]);
      Par.DesviosPadraoEntrada = StringToDouble(xx[4]);
      Par.DesviosPadraoSaida = StringToDouble(xx[5]);
      
      Pares.Add(Par);
    }
  #endif
  
  return true;
}


int OnInit() {
  const ENUM_TIMEFRAMES PeriodoPermitido = PERIOD_H1;
  
  if (Period() != PeriodoPermitido) {
    Alert("Período Gráfico Inválido! Operar apenas no Gráfico H1.");
    return INIT_FAILED;
  }
  
  NumeroMagicoBase = dNumeroMagico;
  Trade = new CTrade();
  Pares = new CList();
  Robo = new CRobo(iHorarioInicialEntrada, iHorarioFinalEntrada, iOperacoesSimultaneas, iIniciarAposLeilao);
  
  ChecarLiquidez = Robo.GetTipoExecucao() == Backteste || iFatorMultiplicadorBook == 0 ? false : true;
  
  if (!CarregarConfiguracao()) {
    Print("Erro na String de Configuração");
    return INIT_FAILED;
  }
  
  CPar::CarregarHistorico(PeriodoPermitido);
  
  if (ChecarLiquidez) {
    CPar::AdicionarMonitoramentoBook();
    Interface = new CInterface(iQuantidadeColunas);
  }
  
  EventSetTimer(1);
  return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason) {
  EventKillTimer();
  
  if (ChecarLiquidez) {
    CPar::RemoverMonitoramentoBook();
    delete Interface;
  }
    
  delete Robo;
  delete Pares;
  delete Trade;
}


double CalcularCapitalPar() {
  double Capital = iCapitalAtual;
  
  if (Capital == 0) //Caso não seja informado capital, pegará o saldo da conta
    Capital = AccountInfoDouble(ACCOUNT_BALANCE);
  
  //Considera apenas o Capital a ser utilizado
  Capital = Capital * (iPercentualCapital / 100);
  
  //Aplica fator multiplicador da alavancagem
  Capital = Capital * iAlavancagem;
  
  //Divide pela quantidade de operações simultaneas
  Capital = Capital / iOperacoesSimultaneas;
  
  return Capital;
}


void OnTimer() {
  if (Robo.EmProcessamento)
    return;
  
  Robo.EmProcessamento = true;
  
  const datetime HorarioAberturaBolsa = StringToTime("09:55:00");
  const datetime HorarioEncerramentoBolsa = StringToTime("18:05:00");
  
  if (TimeCurrent() < HorarioAberturaBolsa  || TimeCurrent() > HorarioEncerramentoBolsa) {
    Robo.EmProcessamento = false;
    return;
  }
    
  if (!CPar::AtualizarStatusPares(PERIOD_H1)) {
    Robo.EmProcessamento = false;
    return;
  }
  
  CPar *Par;
  
  //Entrada nas Operações
  if (Robo.GetStatus() == Ativo) {
    Par = Pares.GetFirstNode();
    
    while (Par != NULL) {
      if (Par.Status == Pronto && Par.Processamento == Finalizado && CPar::GetQuantidadeOperacoes() < iOperacoesSimultaneas && !Par.AtivoCompraEmLeilao && !Par.AtivoVendaEmLeilao) {
        EnumDirecao SinalEntrada = Par.ObterSinalEntrada(ChecarLiquidez, CalcularCapitalPar());
        if (SinalEntrada != Indefinido) {
          if (!Par.RealizarEntrada(SinalEntrada)) {
            Alert("Erro ao Abrir Posição do Par " + Par.AtivoCompra + " vs " + Par.AtivoVenda);
          }
        }
      }
      
      Par = Pares.GetNextNode();
    }
  }
  
  
  //Saída das Operações
  Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    if ((Par.Status == Comprado || Par.Status == Vendido) && Par.Processamento == Finalizado && !Par.AtivoCompraEmLeilao && !Par.AtivoVendaEmLeilao) {
      bool SinalSaida = Par.ObterSinalSaida(ChecarLiquidez);
      
      if (SinalSaida) {
        if (!Par.RealizarSaida()) {
          Alert("Erro ao Encerrar Posição do Par " + Par.AtivoCompra + " vs " + Par.AtivoVenda);
        }
      }
    }
    
    Par = Pares.GetNextNode();
  }
  
  
  //Encerrando operações final do dia
  if (TimeCurrent() >= StringToTime(HorarioToString(iHorarioEncerramentoOperacoes))) {
    Par = Pares.GetFirstNode();
    
    while (Par != NULL) {
      if ((Par.Status == Comprado || Par.Status == Vendido) && Par.Processamento == Finalizado && !Par.AtivoCompraEmLeilao && !Par.AtivoVendaEmLeilao) {
        if (!Par.RealizarSaida()) {
          Alert("Erro ao Encerrar Posição do Par " + Par.AtivoCompra + " vs " + Par.AtivoVenda);
        }
      }
      
      Par = Pares.GetNextNode();
    }
  }
  
  
  if (Robo.GetTipoExecucao() != Backteste && iExibirInterface)
    Interface.AtualizarInterface();
  
  Robo.EmProcessamento = false;
}


void OnTrade() {
  
}

