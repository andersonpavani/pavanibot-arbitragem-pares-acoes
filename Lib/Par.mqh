//+------------------------------------------------------------------+
//|                                                          Par.mqh |
//|                                           Anderson Campos Pavani |
//|                   https://www.andersonpavani.com.br/market/robos |
//+------------------------------------------------------------------+

#property copyright "Anderson Campos Pavani"
#property link "https://www.andersonpavani.com.br/market/robos"


#include <Trade\Trade.mqh>
#include <Object.mqh>
#include <Arrays/List.mqh>
#include "Enumeradores.mqh"
#include "Robo.mqh"


//Variáveis Globais (Não consegui fazer funcionar com Variável Estática dentro da classe)
CTrade *Trade;
CList *Pares;
int NumeroMagicoBase;


class CPar : public CObject {
public:
  //Parametros de Entrada
  int NumeroMagico;
  string AtivoCompra;
  string AtivoVenda;
  int PeriodosMediaMovel;
  double DesviosPadraoEntrada;
  double DesviosPadraoSaida;
  
  //Valores Calculados
  double Ratio;
  double PrecoCompraSintetico;
  double PrecoVendaSintetico;
  double MediaMovelSintetica;
  double DesvioPadraoSintetico;
  
  double VolumeAtivoCompraTotal;
  double VolumeAtivoCompraF;
  double VolumeAtivoCompra;
  double VolumeAtivoVendaTotal;
  double VolumeAtivoVendaF;
  double VolumeAtivoVenda;
  
  //Informações de Entrada do Ativo de Compra
  EnumDirecao DirecaoAtivoCompra;
  double PrecoEntradaAtivoCompra;
  double VolumeEntradaAtivoCompra;
  double PrecoEntradaAtivoCompraF;
  double VolumeEntradaAtivoCompraF;
  double PrecoEntradaAtivoCompraTotal;
  double VolumeEntradaAtivoCompraTotal;

  //Informações de Entrada do Ativo de Venda
  EnumDirecao DirecaoAtivoVenda;
  double PrecoEntradaAtivoVenda;
  double VolumeEntradaAtivoVenda;
  double PrecoEntradaAtivoVendaF;
  double VolumeEntradaAtivoVendaF;
  double PrecoEntradaAtivoVendaTotal;
  double VolumeEntradaAtivoVendaTotal;
  
  //Informações Gerais
  EnumParStatus Status;
  double PrecoEntradaSintetico;
  datetime DatahoraEntrada;
  double ResultadoAtual;
  bool BuscandoLiquidez;
  
  EnumStatusProcessamento Processamento;
  bool AtivoCompraEmLeilao;
  bool AtivoVendaEmLeilao;


  CPar();
  ~CPar();
  
  static CPar *ParPorNumeroMagico(const int NumeroMagico);
  static bool AtualizarStatusPares(ENUM_TIMEFRAMES PeriodoGrafico);
  static int GetQuantidadeOperacoes();
  static bool ObtemPrecoBook(const string Ativo, const EnumDirecao Direcao, const double Volume, double &Preco);
  bool RealizarEntrada(const EnumDirecao Direcao);
  bool RealizarSaida();
  EnumDirecao ObterSinalEntrada(const bool VerificarLiquidez, const double Capital);
  bool ObterSinalSaida(const bool VerificarLiquidez);
  static void CarregarHistorico(ENUM_TIMEFRAMES Periodo);
  static void AdicionarMonitoramentoBook();
  static void RemoverMonitoramentoBook();
};

CPar::CPar() {
  Status = Pronto;
  DirecaoAtivoCompra = Indefinido;
  DirecaoAtivoVenda = Indefinido;
  Processamento = Finalizado;
  AtivoCompraEmLeilao = true;
  AtivoVendaEmLeilao = true;
  PrecoEntradaAtivoCompra = 0;
  PrecoEntradaAtivoCompraF = 0;
  PrecoEntradaAtivoVenda = 0;
  PrecoEntradaAtivoVendaF = 0;
  BuscandoLiquidez = false;
}

CPar::~CPar() {
}

static CPar *CPar::ParPorNumeroMagico(const int NumeroMagico) {
  int BookMark = Pares.IndexOf(Pares.GetCurrentNode());
  
  CPar *Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    if (Par.NumeroMagico == NumeroMagico) {
      Pares.MoveToIndex(BookMark);
      return Par;
    }
    
    Par = Pares.GetNextNode();
  }
  
  Pares.GetNodeAtIndex(BookMark);
  return NULL;
}

static bool CPar::AtualizarStatusPares(ENUM_TIMEFRAMES PeriodoGrafico) {
  static string RegistroData = "";
  string Hoje = TimeToString(TimeCurrent(), TIME_DATE);
  bool VirouDia = false;
  
  if (RegistroData != Hoje) {
    RegistroData = Hoje;
    VirouDia = true;
  }
  
  CPar *Par;
  
  //Colocar Ativos em Leilão
  Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    if (VirouDia) {
      Par.AtivoCompraEmLeilao = true;
      Par.AtivoVendaEmLeilao = true;
    }

    Par = Pares.GetNextNode();
  }
  
  
  Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    double PrecoAtivoCompra = SymbolInfoDouble(Par.AtivoCompra, SYMBOL_BID);
    double PrecoAtivoVenda = SymbolInfoDouble(Par.AtivoVenda, SYMBOL_BID);
    Par.Ratio = PrecoAtivoCompra / PrecoAtivoVenda;
    
    
    double FechamentosAtivoCompra[];
    ArraySetAsSeries(FechamentosAtivoCompra, true);
    int ResCopyRatesAtivoCompra = CopyClose(Par.AtivoCompra, PeriodoGrafico, 0, Par.PeriodosMediaMovel, FechamentosAtivoCompra);
    
    double FechamentosAtivoVenda[];
    ArraySetAsSeries(FechamentosAtivoVenda, true);
    int ResCopyRatesAtivoVenda = CopyClose(Par.AtivoVenda, PeriodoGrafico, 0, Par.PeriodosMediaMovel, FechamentosAtivoVenda);
    
    if (ResCopyRatesAtivoCompra != Par.PeriodosMediaMovel || ResCopyRatesAtivoVenda != Par.PeriodosMediaMovel) {
      Alert("Erro ao carregar Preços de Fechamento do Ativo " + Par.AtivoCompra + " ou " + Par.AtivoVenda);
      return false;
    }
    
    //Calculando Média Móvel
    double FechamentosSinteticos[];
    ArrayResize(FechamentosSinteticos, Par.PeriodosMediaMovel);
    double SomaFechamentosSinteticos = 0;
    
    for (int i = 0; i < Par.PeriodosMediaMovel; i++) {
      FechamentosSinteticos[i] = FechamentosAtivoCompra[i] / FechamentosAtivoVenda[i];
      SomaFechamentosSinteticos += FechamentosSinteticos[i];
    }
    
    Par.MediaMovelSintetica = SomaFechamentosSinteticos / Par.PeriodosMediaMovel;
    
    
    //Calculando Desvio Padrão
    //Calcular o quadrado da distância de cada valor da média e calculando sua média
    double MediaQuadrados = 0;
    double Valores[];
    ArrayResize(Valores, Par.PeriodosMediaMovel);
    
    for (int i = 0; i < Par.PeriodosMediaMovel; i++) {
      Valores[i] = MathPow(MathAbs(FechamentosSinteticos[i] - Par.MediaMovelSintetica), 2);
      MediaQuadrados += Valores[i];
    }
    
    MediaQuadrados = MediaQuadrados / Par.PeriodosMediaMovel;
    
    //Calcular a raiz quadrada da média dos quadrados da etapa anterior
    Par.DesvioPadraoSintetico = MathSqrt(MediaQuadrados);
    
    
    //Calculando Preços sintéticos
    double AtivoCompraBid = SymbolInfoDouble(Par.AtivoCompra, SYMBOL_BID);
    double AtivoCompraAsk = SymbolInfoDouble(Par.AtivoCompra, SYMBOL_ASK);
    double AtivoVendaBid = SymbolInfoDouble(Par.AtivoVenda, SYMBOL_BID);
    double AtivoVendaAsk = SymbolInfoDouble(Par.AtivoVenda, SYMBOL_ASK);
    
    if (AtivoCompraAsk == 0 || AtivoCompraBid == 0 || AtivoVendaAsk == 0 || AtivoVendaBid == 0) {
      Print("Não foi possível obter preço de um dos ativos. Possível queda de conexão.");
      return false;
    }
    
    Par.PrecoCompraSintetico = AtivoCompraAsk / AtivoVendaBid;
    Par.PrecoVendaSintetico = AtivoCompraBid / AtivoVendaAsk;
    
    Par.PrecoEntradaAtivoCompra = 0;
    Par.PrecoEntradaAtivoCompraF = 0;
    Par.PrecoEntradaAtivoCompraTotal = 0;
    Par.PrecoEntradaAtivoVenda = 0;
    Par.PrecoEntradaAtivoVendaF = 0;
    Par.PrecoEntradaAtivoVendaTotal = 0;
    
    Par.Status = Robo.GetStatus() == Ativo ? Pronto : Pausado;
    
    if (AtivoCompraBid >= AtivoCompraAsk)
      Par.AtivoCompraEmLeilao = true;
    
    if (AtivoVendaBid >= AtivoVendaAsk)
      Par.AtivoVendaEmLeilao = true;
    
    Par = Pares.GetNextNode();
  }
  
  
  int TotalPosicoes = PositionsTotal();
  
  for (int i = 0; i < TotalPosicoes; i++) {
    if (!PositionSelectByTicket(PositionGetTicket(i)))
      continue;
    
    ulong NumeroMagico = PositionGetInteger(POSITION_MAGIC);
    
    Par = ParPorNumeroMagico((int)(NumeroMagico - NumeroMagicoBase));
    
    if (Par == NULL)
      continue;
    
    string Ativo = PositionGetString(POSITION_SYMBOL);
    double PrecoEntrada = PositionGetDouble(POSITION_PRICE_OPEN);
    double VolumeEntrada = PositionGetDouble(POSITION_VOLUME);
    EnumDirecao Direcao = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? Compra : Venda;
    Par.DatahoraEntrada = (datetime)PositionGetInteger(POSITION_TIME);
    
    if (Ativo == Par.AtivoCompra || Ativo == Par.AtivoCompra + "F")
      if (Par.DirecaoAtivoCompra != Direcao)
        Par.DirecaoAtivoCompra = Direcao;
    
    if (Ativo == Par.AtivoVenda || Ativo == Par.AtivoVenda + "F")
      if (Par.DirecaoAtivoVenda != Direcao)
        Par.DirecaoAtivoVenda = Direcao;
    
    if (Ativo == Par.AtivoCompra) {
      Par.PrecoEntradaAtivoCompra = PrecoEntrada;
      Par.VolumeEntradaAtivoCompra = VolumeEntrada;
    }
    
    if (Ativo == Par.AtivoCompra + "F") {
      Par.PrecoEntradaAtivoCompraF = PrecoEntrada;
      Par.VolumeEntradaAtivoCompraF = VolumeEntrada;
    }
    
    if (Ativo == Par.AtivoVenda) {
      Par.PrecoEntradaAtivoVenda = PrecoEntrada;
      Par.VolumeEntradaAtivoVenda = VolumeEntrada;
    }
    
    if (Ativo == Par.AtivoVenda + "F") {
      Par.PrecoEntradaAtivoVendaF = PrecoEntrada;
      Par.VolumeEntradaAtivoVendaF = VolumeEntrada;
    }
  }
  
  
  Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    
    if (Par.Processamento == Finalizado) {
      if (Par.PrecoEntradaAtivoCompra != 0 || Par.PrecoEntradaAtivoCompraF != 0 || Par.PrecoEntradaAtivoVenda != 0 || Par.PrecoEntradaAtivoVendaF != 0) {
        if (Par.DirecaoAtivoCompra != Indefinido) {
          Par.Status = Par.DirecaoAtivoCompra == Compra ? Comprado : Vendido;
        } else {
          Par.Status = Par.DirecaoAtivoVenda == Venda ? Comprado : Vendido;
        }
      }
    }
      
    if (Par.Processamento == Entrando
    && (Par.VolumeAtivoCompra == 0 || Par.PrecoEntradaAtivoCompra != 0)
    && (Par.VolumeAtivoCompraF == 0 || Par.PrecoEntradaAtivoCompraF != 0)
    && (Par.VolumeAtivoVenda == 0 || Par.PrecoEntradaAtivoVenda != 0)
    && (Par.VolumeAtivoVendaF == 0 || Par.PrecoEntradaAtivoVendaF != 0)) {
      Par.Processamento = Finalizado;
      
      if (Par.DirecaoAtivoCompra != Indefinido) {
        Par.Status = Par.DirecaoAtivoCompra == Compra ? Comprado : Vendido;
      } else {
        Par.Status = Par.DirecaoAtivoVenda == Venda ? Comprado : Vendido;
      }
    }
    
    if (Par.Processamento == Saindo) {
      if (Par.PrecoEntradaAtivoCompra == 0 && Par.PrecoEntradaAtivoCompraF == 0 && Par.PrecoEntradaAtivoVenda == 0 && Par.PrecoEntradaAtivoVendaF == 0) {
        Par.Processamento = Finalizado;
        Par.Status = Robo.GetStatus() == Ativo ? Pronto : Pausado;
      }
    }
    
    if (Par.Status == Comprado || Par.Status == Vendido) {
      Par.VolumeEntradaAtivoCompraTotal = Par.VolumeEntradaAtivoCompra + Par.VolumeEntradaAtivoCompraF;
      Par.PrecoEntradaAtivoCompraTotal = ((Par.PrecoEntradaAtivoCompra * Par.VolumeEntradaAtivoCompra) + (Par.PrecoEntradaAtivoCompraF * Par.VolumeEntradaAtivoCompraF)) / Par.VolumeEntradaAtivoCompraTotal;
      Par.VolumeEntradaAtivoVendaTotal = Par.VolumeEntradaAtivoVenda + Par.VolumeEntradaAtivoVendaF;
      Par.PrecoEntradaAtivoVendaTotal = ((Par.PrecoEntradaAtivoVenda * Par.VolumeEntradaAtivoVenda) + (Par.PrecoEntradaAtivoVendaF * Par.VolumeEntradaAtivoVendaF)) / Par.VolumeEntradaAtivoVendaTotal;
      Par.PrecoEntradaSintetico = Par.PrecoEntradaAtivoCompraTotal / Par.PrecoEntradaAtivoVendaTotal;
      
      double FinanceiroEntradaAtivoCompra = (Par.PrecoEntradaAtivoCompra * Par.VolumeEntradaAtivoCompra) + (Par.PrecoEntradaAtivoCompraF * Par.VolumeEntradaAtivoCompraF);
      double FinanceiroEntradaAtivoVenda = (Par.PrecoEntradaAtivoVenda * Par.VolumeEntradaAtivoVenda) + (Par.PrecoEntradaAtivoVendaF * Par.VolumeEntradaAtivoVendaF);

      if (Par.Status == Comprado) {
        double AtivoCompraBid = SymbolInfoDouble(Par.AtivoCompra, SYMBOL_BID);
        double AtivoVendaAsk = SymbolInfoDouble(Par.AtivoVenda, SYMBOL_ASK);

        double FinanceiroAtualAtivoCompra = (AtivoCompraBid * Par.VolumeEntradaAtivoCompra) + (AtivoCompraBid * Par.VolumeEntradaAtivoCompraF);
        double FinanceiroAtualAtivoVenda = (AtivoVendaAsk * Par.VolumeEntradaAtivoVenda) + (AtivoVendaAsk * Par.VolumeEntradaAtivoVendaF);
        
        Par.ResultadoAtual = (FinanceiroAtualAtivoCompra - FinanceiroEntradaAtivoCompra) + (FinanceiroEntradaAtivoVenda - FinanceiroAtualAtivoVenda);
      }
      
      if (Par.Status == Vendido) {
        double AtivoCompraAsk = SymbolInfoDouble(Par.AtivoCompra, SYMBOL_ASK);
        double AtivoVendaBid = SymbolInfoDouble(Par.AtivoVenda, SYMBOL_BID);

        double FinanceiroAtualAtivoCompra = (AtivoCompraAsk * Par.VolumeEntradaAtivoCompra) + (AtivoCompraAsk * Par.VolumeEntradaAtivoCompraF);
        double FinanceiroAtualAtivoVenda = (AtivoVendaBid * Par.VolumeEntradaAtivoVenda) + (AtivoVendaBid * Par.VolumeEntradaAtivoVendaF);
        
        Par.ResultadoAtual = (FinanceiroEntradaAtivoCompra - FinanceiroAtualAtivoCompra) + (FinanceiroAtualAtivoVenda - FinanceiroEntradaAtivoVenda);
      }
    }
    
    Par = Pares.GetNextNode();
  }
  
  
  if (CPar::GetQuantidadeOperacoes() >= Robo.GetQuantidadeOperacoesSimultaneas()) {
    Par = Pares.GetFirstNode();
    
    while (Par != NULL) {
      if (Par.Status == Pronto)
        Par.Status = Pausado;
        
      Par = Pares.GetNextNode();
    }
  }
  
  //Retirar do Leilão
  Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    if (Par.AtivoCompraEmLeilao || Par.AtivoVendaEmLeilao) {
      MqlTick UltimoTick;
      
      if (Par.AtivoCompraEmLeilao) {
        SymbolInfoTick(Par.AtivoCompra, UltimoTick);
        
        if (UltimoTick.volume > 0)
          Par.AtivoCompraEmLeilao = false;
      }
      
      if (Par.AtivoVendaEmLeilao) {
        SymbolInfoTick(Par.AtivoVenda, UltimoTick);
        
        if (UltimoTick.volume > 0)
          Par.AtivoVendaEmLeilao = false;
      }
    }
    
    Par = Pares.GetNextNode();
  }
  
  return true;
}

static int CPar::GetQuantidadeOperacoes() {
  int BookMark = Pares.IndexOf(Pares.GetCurrentNode());
  
  CPar *Par = Pares.GetFirstNode();
  int TotalOperacoes = 0;
  
  while (Par != NULL) {
    if (Par.Status == Pronto && Par.Processamento == Entrando)
      TotalOperacoes++;

    if ((Par.Status == Comprado || Par.Status == Vendido) && Par.Processamento == Finalizado)
      TotalOperacoes++;
    
    Par = Pares.GetNextNode();
  }
  
  Pares.GetNodeAtIndex(BookMark);
  
  return TotalOperacoes;
}

bool CPar::RealizarEntrada(const EnumDirecao Direcao) {
  Trade.SetExpertMagicNumber(NumeroMagico + NumeroMagicoBase);
  
  Processamento = Entrando;
  
  //Realizando Entrada
  if (Direcao == Compra) {
    
    if (VolumeAtivoCompra > 0) {
      if (!Trade.Buy(VolumeAtivoCompra, AtivoCompra, 0, 0, 0, NULL)) {
        Alert("Erro ao realizar compra a mercado do Ativo de Compra " + AtivoCompra + " | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }

    if (VolumeAtivoCompraF > 0) {
      if (!Trade.Buy(VolumeAtivoCompraF, AtivoCompra + "F", 0, 0, 0, NULL)) {
        Alert("Erro ao realizar compra a mercado do Ativo de Compra " + AtivoCompra + " | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }

    if (VolumeAtivoVenda > 0) {
      if (!Trade.Sell(VolumeAtivoVenda, AtivoVenda, 0, 0, 0, NULL)) {
        Alert("Erro ao realizar venda a mercado do Ativo de Venda " + AtivoVenda + " | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }
    
    if (VolumeAtivoVendaF > 0) {
      if (!Trade.Sell(VolumeAtivoVendaF, AtivoVenda + "F", 0, 0, 0, NULL)) {
        Alert("Erro ao realizar venda a mercado do Ativo de Venda " + AtivoVenda + "F | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }

  } else { //Venda
    
    if (VolumeAtivoVenda > 0) {
      if (!Trade.Buy(VolumeAtivoVenda, AtivoVenda, 0, 0, 0, NULL)) {
        Alert("Erro ao realizar compra a mercado do Ativo de Venda " + AtivoVenda + " | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }

    if (VolumeAtivoVendaF > 0) {
      if (!Trade.Buy(VolumeAtivoVendaF, AtivoVenda + "F", 0, 0, 0, NULL)) {
        Alert("Erro ao realizar compra a mercado do Ativo de Venda " + AtivoVenda + "F | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }

    if (VolumeAtivoCompra > 0) {
      if (!Trade.Sell(VolumeAtivoCompra, AtivoCompra, 0, 0, 0, NULL)) {
        Alert("Erro ao realizar venda a mercado do Ativo de Compra " + AtivoCompra + " | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }

    if (VolumeAtivoCompraF > 0) {
      if (!Trade.Sell(VolumeAtivoCompraF, AtivoCompra + "F", 0, 0, 0, NULL)) {
        Alert("Erro ao realizar venda a mercado do Ativo de Compra " + AtivoCompra + " | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
        return false;
      }
    }
  }
  
  return true;
}

bool CPar::RealizarSaida() {
  Processamento = Saindo;
  
  int TotalPosicoes = PositionsTotal();
  ulong TicketsCompra[];
  ulong TicketsVenda[];
  
  for (int i = 0; i < TotalPosicoes; i++) {
    ulong Ticket = PositionGetTicket(i);
  
    if (PositionSelectByTicket(Ticket)) {
      ulong NumeroMagicoPosicao = PositionGetInteger(POSITION_MAGIC);
      string Ativo = PositionGetString(POSITION_SYMBOL);
     
      if (NumeroMagicoPosicao == NumeroMagico + NumeroMagicoBase && (Ativo == AtivoCompra || Ativo == AtivoCompra + "F" || Ativo == AtivoVenda || Ativo == AtivoVenda + "F")) {
        if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
          ArrayResize(TicketsCompra, ArraySize(TicketsCompra) + 1, 0);
          TicketsCompra[ArraySize(TicketsCompra) - 1] = Ticket;
        } else {
          ArrayResize(TicketsVenda, ArraySize(TicketsVenda) + 1, 0);
          TicketsVenda[ArraySize(TicketsVenda) - 1] = Ticket;
        }
      }
    }
  }
  
  for (int i = 0; i < ArraySize(TicketsVenda); i++) {
    if (!Trade.PositionClose(TicketsVenda[i])) {
      Alert("Erro ao Fechar Posicição " + IntegerToString(TicketsVenda[i]) + ". Encerre as operações abertas nos ativos imediatamente! | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
      return false;
    }
  }

  for (int i = 0; i < ArraySize(TicketsCompra); i++) {
    if (!Trade.PositionClose(TicketsCompra[i])) {
      Alert("Erro ao Fechar Posicição " + IntegerToString(TicketsCompra[i]) + ". Encerre as operações abertas nos ativos imediatamente! | ResultRetcode: " + IntegerToString(Trade.ResultRetcode()));
      return false;
    }
  }
  
  return true;
}

static bool CPar::ObtemPrecoBook(const string Ativo, const EnumDirecao Direcao, const double Volume, double &Preco) {
  MqlBookInfo BookAtivo[];

  if (!MarketBookGet(Ativo, BookAtivo)) {
    Alert("Erro ao recuperar book do ativo " + Ativo);
    return false;
  }
  
  double PrecoMedio = 0;
  double VolumeRestante = Volume;
  
  if (Direcao == Compra) {
    for (int i = ArraySize(BookAtivo) - 1; i >= 0; i--) {
      if (BookAtivo[i].type == BOOK_TYPE_BUY)
        continue;
      
      if (BookAtivo[i].volume >= VolumeRestante) {
        PrecoMedio += BookAtivo[i].price * VolumeRestante;
        VolumeRestante = 0;
        break;
      } else {
        PrecoMedio += BookAtivo[i].price * BookAtivo[i].volume_real;
        VolumeRestante -= BookAtivo[i].volume_real;
      }
    }
  } else {
    for (int i = 0; i < ArraySize(BookAtivo); i++) {
      if (BookAtivo[i].type == BOOK_TYPE_SELL)
        continue;
      
      if (BookAtivo[i].volume >= VolumeRestante) {
        PrecoMedio += BookAtivo[i].price * VolumeRestante;
        VolumeRestante = 0;
        break;
      } else {
        PrecoMedio += BookAtivo[i].price * BookAtivo[i].volume_real;
        VolumeRestante -= BookAtivo[i].volume_real;
      }
    }
  }

  
  if (VolumeRestante != 0)
    return false;
  
  PrecoMedio = PrecoMedio / Volume;
  PrecoMedio = round(PrecoMedio * 1000) / 1000;
  Preco = PrecoMedio;
  
  return true;
}

EnumDirecao CPar::ObterSinalEntrada(const bool VerificarLiquidez, const double Capital) {
  EnumDirecao Res = Indefinido;
  
  if (PrecoCompraSintetico <= MediaMovelSintetica - (DesvioPadraoSintetico * DesviosPadraoEntrada))
    Res = Compra;
  
  if (PrecoVendaSintetico >= MediaMovelSintetica + (DesvioPadraoSintetico * DesviosPadraoEntrada))
    Res = Venda;
  
  
  //Calculando Volume
  if (Res != Indefinido) {
    double PrecoAtivoCompra = SymbolInfoDouble(AtivoCompra, SYMBOL_BID);
    double PrecoAtivoVenda = SymbolInfoDouble(AtivoVenda, SYMBOL_BID);

    VolumeAtivoCompraTotal = round(Capital / (PrecoAtivoCompra * 2));
    VolumeAtivoCompraF = MathMod(VolumeAtivoCompraTotal, 100);
    VolumeAtivoCompra = VolumeAtivoCompraTotal - VolumeAtivoCompraF;
  
    VolumeAtivoVendaTotal = round(VolumeAtivoCompraTotal * Ratio);
    VolumeAtivoVendaF = MathMod(VolumeAtivoVendaTotal, 100);
    VolumeAtivoVenda = VolumeAtivoVendaTotal - VolumeAtivoVendaF;
  }
  
  
  //Calculando Preço de Entrada considerando Fracionário
  
  
  if (!VerificarLiquidez || Res == Indefinido) {
    BuscandoLiquidez = false;
    return Res;
  }
  
  BuscandoLiquidez = true;
  
  //Verificando Book de Ofertas para encontrar liquidez
  double PrecoAtivoCompra = 0;
  double PrecoAtivoCompraF = 0;
  double PrecoAtivoVenda = 0;
  double PrecoAtivoVendaF = 0;
  
  EnumDirecao ResInvertido = Res == Compra ? Venda : Compra;
  
  if (VolumeAtivoCompra > 0)
    if(!CPar::ObtemPrecoBook(AtivoCompra, Res, VolumeAtivoCompra, PrecoAtivoCompra))
      return Indefinido;
  
  if (VolumeAtivoCompraF > 0)
    if(!CPar::ObtemPrecoBook(AtivoCompra + "F", Res, VolumeAtivoCompraF, PrecoAtivoCompraF))
      return Indefinido;
  
  if (VolumeAtivoVenda > 0)
    if(!CPar::ObtemPrecoBook(AtivoVenda, ResInvertido, VolumeAtivoVenda, PrecoAtivoVenda))
      return Indefinido;
  
  if (VolumeAtivoVendaF > 0)
    if(!CPar::ObtemPrecoBook(AtivoVenda + "F", ResInvertido, VolumeAtivoVendaF, PrecoAtivoVendaF))
      return Indefinido;
  
  if (PrecoAtivoCompra == 0)
    PrecoAtivoCompra = PrecoAtivoCompraF;
  
  if (PrecoAtivoCompraF == 0)
    PrecoAtivoCompraF = PrecoAtivoCompra;
  
  if (PrecoAtivoVenda == 0)
    PrecoAtivoVenda = PrecoAtivoVendaF;
  
  if (PrecoAtivoVendaF == 0)
    PrecoAtivoVendaF = PrecoAtivoVenda;
  
  double PrecoAtivoCompraMedio = (((PrecoAtivoCompra * VolumeAtivoCompra) + (PrecoAtivoCompraF * VolumeAtivoCompraF)) / VolumeAtivoCompraTotal);
  double PrecoAtivoVendaMedio = (((PrecoAtivoVenda * VolumeAtivoVenda) + (PrecoAtivoVendaF * VolumeAtivoVendaF)) / VolumeAtivoVendaTotal);

  double PrecoTeorico = PrecoAtivoCompraMedio / PrecoAtivoVendaMedio;
 
  
  EnumDirecao ResBook = Indefinido;
  
  if (Res == Compra) 
    if (PrecoTeorico <= MediaMovelSintetica - (DesvioPadraoSintetico * DesviosPadraoEntrada))
      ResBook = Compra;
  
  if (Res == Venda)
    if (PrecoTeorico >= MediaMovelSintetica + (DesvioPadraoSintetico * DesviosPadraoEntrada))
      ResBook = Venda;
  
  return ResBook;
}

bool CPar::ObterSinalSaida(const bool VerificarLiquidez) {
  bool Res = false;
  
  if (Status == Comprado) {
    if (PrecoVendaSintetico >= MediaMovelSintetica - (DesvioPadraoSintetico * DesviosPadraoSaida))
      Res = true;
  } else {
    if (PrecoCompraSintetico <= MediaMovelSintetica + (DesvioPadraoSintetico * DesviosPadraoSaida))
      Res = true;
  }
  
  if (!VerificarLiquidez || Res == false) {
    BuscandoLiquidez = false;
    return Res;
  }
  
  BuscandoLiquidez = true;
  
  //Verificando Book de Ofertas para encontrar liquidez
  double PrecoAtivoCompra = 0;
  double PrecoAtivoCompraF = 0;
  double PrecoAtivoVenda = 0;
  double PrecoAtivoVendaF = 0;
  
  EnumDirecao SinalSaida = Status == Comprado ? Venda : Compra;
  EnumDirecao SinalSaidaInvertido = Status == Comprado ? Compra : Venda;
  
  
  if (VolumeEntradaAtivoCompra > 0)
    if(!CPar::ObtemPrecoBook(AtivoCompra, SinalSaida, VolumeEntradaAtivoCompra, PrecoAtivoCompra))
      return false;
  
  if (VolumeEntradaAtivoCompraF > 0)
    if(!CPar::ObtemPrecoBook(AtivoCompra + "F", SinalSaida, VolumeEntradaAtivoCompraF, PrecoAtivoCompraF))
      return false;
  
  if (VolumeEntradaAtivoVenda > 0)
    if(!CPar::ObtemPrecoBook(AtivoVenda, SinalSaidaInvertido, VolumeEntradaAtivoVenda, PrecoAtivoVenda))
      return false;
  
  if (VolumeEntradaAtivoVendaF > 0)
    if(!CPar::ObtemPrecoBook(AtivoVenda + "F", SinalSaidaInvertido, VolumeEntradaAtivoVendaF, PrecoAtivoVendaF))
      return false;
  

  double PrecoAtivoCompraMedia = ((PrecoAtivoCompra * VolumeEntradaAtivoCompra) + (PrecoAtivoCompraF * VolumeEntradaAtivoCompraF)) / VolumeEntradaAtivoCompraTotal;
  double PrecoAtivoVendaMedia = ((PrecoAtivoVenda * VolumeEntradaAtivoVenda) + (PrecoEntradaAtivoVendaF * VolumeEntradaAtivoVendaF)) / VolumeEntradaAtivoVendaTotal;

  double PrecoBookSintetico = PrecoAtivoCompraMedia / PrecoAtivoVendaMedia;
  
  if (Status == Comprado) {
    return PrecoBookSintetico >= MediaMovelSintetica - (DesvioPadraoSintetico * DesviosPadraoSaida);
  } else {
    return PrecoBookSintetico <= MediaMovelSintetica + (DesvioPadraoSintetico * DesviosPadraoSaida);
  }
}

static void CPar::CarregarHistorico(ENUM_TIMEFRAMES Periodo) {
  CPar *Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    SeriesInfoInteger(Par.AtivoCompra, Periodo, SERIES_FIRSTDATE);
    SeriesInfoInteger(Par.AtivoCompra + "F", Periodo, SERIES_FIRSTDATE);
    SeriesInfoInteger(Par.AtivoVenda, Periodo, SERIES_FIRSTDATE);
    SeriesInfoInteger(Par.AtivoVenda + "F", Periodo, SERIES_FIRSTDATE);
    
    Par = Pares.GetNextNode();
  }
}

static void CPar::AdicionarMonitoramentoBook() {
  CPar *Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    MarketBookAdd(Par.AtivoCompra);
    MarketBookAdd(Par.AtivoCompra + "F");
    MarketBookAdd(Par.AtivoVenda);
    MarketBookAdd(Par.AtivoVenda + "F");
    
    Par = Pares.GetNextNode();
  }
}

static void CPar::RemoverMonitoramentoBook() {
  CPar *Par = Pares.GetFirstNode();
  
  while (Par != NULL) {
    MarketBookRelease(Par.AtivoCompra);
    MarketBookRelease(Par.AtivoCompra + "F");
    MarketBookRelease(Par.AtivoVenda);
    MarketBookRelease(Par.AtivoVenda + "F");
    
    Par = Pares.GetNextNode();
  }
}
