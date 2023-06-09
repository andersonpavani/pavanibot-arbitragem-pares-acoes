//+------------------------------------------------------------------+
//|                                                    Interface.mqh |
//|                                           Anderson Campos Pavani |
//|                   https://www.andersonpavani.com.br/market/robos |
//+------------------------------------------------------------------+
#property copyright "Anderson Campos Pavani"
#property link      "https://www.andersonpavani.com.br/market/robos"


#include <Controls\Panel.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include "..\Lib\Robo.mqh"
#include "..\Lib\Par.mqh"


class CInterfacePar : public CObject {
public:
  int NumeroMagico;
  CPanel PainelPar;
  CPanel PainelParTitulo;
  CLabel TextoPar;
  CLabel StatusParRotulo;
  CLabel StatusPar;
  CLabel BandaSuperiorRotulo;
  CLabel BandaSuperior;
  CLabel MediaMovelRotulo;
  CLabel MediaMovel;
  CLabel BandaInferiorRotulo;
  CLabel BandaInferior;
  CLabel PrecoCompraRotulo;
  CLabel PrecoCompra;
  CLabel PrecoVendaRotulo;
  CLabel PrecoVenda;
  CLabel AlvoRotulo;
  
  CPanel BarraPar;
  CPanel BarraParBandaSuperior;
  CPanel BarraParMediaMovel;
  CPanel BarraParBandaInferior;
  CPanel BarraParPreco;

  CInterfacePar(const int _NumeroMagico);
  ~CInterfacePar();
};

CInterfacePar::CInterfacePar(const int _NumeroMagico) {
  NumeroMagico = _NumeroMagico;
}

CInterfacePar::~CInterfacePar() {
}


class CInterface {
private:
  int QuantidadeColunas;

  CPanel PainelPrincipal;
  CPanel PainelTitulo;
  CLabel TextoTitulo;
  CLabel TextoVersao;
  CPanel PainelStatus;
  CPanel PainelStatusRotulo;
  CLabel TextoRotuloStatus;
  CLabel TextoStatus;
  CButton BotaoDesativar;
  CList *InterfacePares;
  
  void CriarInterface();
  void DestruirInterface();

public:

  CInterface(const int _QuantidadeColunas);
  ~CInterface();
  
  void AtualizarInterface();
};


//Variáveis Globais
CInterface *Interface;
const color CorTituloComponente = C'0xB0,0xBE,0xC5';
const color CorFundoComponente = clrWhite;
const color CorFundoComponenteInativo = C'0xCF,0xD8,0xDC';
const color CorFundoNegociando = C'0xDC,0xED,0xC8';
const color CorFontePadrao = C'0x42,0x42,0x42';
const string FontePadrao = "Calibri";
const int TamanhoFontePadrao = 11;
//const color CorFonteAzul = C'0x01,0x57,0x9B';
const color CorFonteAzul = C'0x45,0x5A,0x64';
const color CorFundoPreco = C'0xCF,0xD8,0xDC';


CInterface::CInterface(const int _QuantidadeColunas) {
  QuantidadeColunas = _QuantidadeColunas;
  InterfacePares = new CList();
  
  CriarInterface();
}

CInterface::~CInterface() {
  DestruirInterface();
  delete InterfacePares;
}


void CInterface::CriarInterface() {
  const int MargemEsquerda = 10;
  const int MargemTopo = 22;
  const int EspacamentoComponentes = 10;
  const int LarguraPainelPar = 202;
  const int AlturaPainelPar = 162;
  
  MqlDateTime DataHoraCompilacao;
  TimeToStruct(__DATETIME__, DataHoraCompilacao);
  string Versao = StringFormat("Versão %04d.%02d.%02d.%04d", DataHoraCompilacao.year, DataHoraCompilacao.mon, DataHoraCompilacao.day, (DataHoraCompilacao.hour * 100) + DataHoraCompilacao.min);
  
  int QuantidadeLinhas = Pares.Total() / QuantidadeColunas;
  int UltimaLinha = Pares.Total() % QuantidadeColunas;
  
  if (UltimaLinha > 0)
    QuantidadeLinhas++;
  
  int LarguraPainelPrincipal = MargemEsquerda + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * QuantidadeColunas);
  int AlturaPainelPrincipal = MargemTopo + 30 + EspacamentoComponentes + 30 + ((EspacamentoComponentes + AlturaPainelPar) * QuantidadeLinhas) + EspacamentoComponentes;
  
  //Painel Principal
  PainelPrincipal.Create(0, "PainelPrincipal", 0, MargemEsquerda, MargemTopo, LarguraPainelPrincipal, AlturaPainelPrincipal);
  PainelPrincipal.ColorBorder(CorTituloComponente);
  PainelPrincipal.ColorBackground(CONTROLS_DIALOG_COLOR_BG);
  
  //Titulo
  PainelTitulo.Create(0, "PainelTitulo", 0, PainelPrincipal.Left(), PainelPrincipal.Top(), PainelPrincipal.Right(), PainelPrincipal.Top() + 30);
  PainelTitulo.ColorBackground(CorTituloComponente);
  
  TextoTitulo.Create(0, "TextoTitulo", 0, PainelPrincipal.Left() + EspacamentoComponentes, PainelPrincipal.Top() + 5, PainelPrincipal.Right(), PainelPrincipal.Top() + 30);
  TextoTitulo.Font(FontePadrao);
  TextoTitulo.FontSize(TamanhoFontePadrao);
  TextoTitulo.Text("PavaniBot - Arbitragem em Pares de Ações - Day Trade");
  
  TextoVersao.Create(0, "TextoVersao", 0, PainelPrincipal.Right() - 145, PainelPrincipal.Top() + 6, PainelPrincipal.Right(), PainelPrincipal.Top() + 30);
  TextoVersao.Font(FontePadrao);
  TextoVersao.FontSize(10);
  TextoVersao.Color(C'0x78,0x90,0x9C');
  TextoVersao.Text(Versao);

  //Botão Desativar
  BotaoDesativar.Create(0, "BotaoDesativar", 0, PainelPrincipal.Right() - EspacamentoComponentes - 100, PainelTitulo.Bottom() + EspacamentoComponentes, PainelPrincipal.Right() - EspacamentoComponentes, PainelTitulo.Bottom() + EspacamentoComponentes + 30);
  BotaoDesativar.Text("Desativar");
  BotaoDesativar.Font(FontePadrao);
  BotaoDesativar.FontSize(TamanhoFontePadrao);
  BotaoDesativar.ColorBackground(C'0xEF,0x9A,0x9A');
  BotaoDesativar.ColorBorder(C'0xE5,0x73,0x73');
  BotaoDesativar.Color(CorFontePadrao);

  //Status
  PainelStatus.Create(0, "PainelStatus", 0, PainelTitulo.Left() + EspacamentoComponentes, PainelTitulo.Bottom() + EspacamentoComponentes, BotaoDesativar.Left() - EspacamentoComponentes, PainelTitulo.Bottom() + EspacamentoComponentes + 30);
  PainelStatus.ColorBorder(CorTituloComponente);
  PainelStatus.ColorBackground(CorFundoComponente);
  
  PainelStatusRotulo.Create(0, "PainelStatusRotulo", 0, PainelTitulo.Left() + EspacamentoComponentes, PainelTitulo.Bottom() + EspacamentoComponentes, PainelPrincipal.Left() + EspacamentoComponentes + 59, PainelTitulo.Bottom() + EspacamentoComponentes + 30);
  PainelStatusRotulo.ColorBackground(CorTituloComponente);
  
  TextoRotuloStatus.Create(0, "TextoRotuloStatus", 0, PainelStatusRotulo.Left() + EspacamentoComponentes, PainelStatusRotulo.Top() + 5, PainelStatusRotulo.Right(), PainelStatusRotulo.Bottom());
  TextoRotuloStatus.Font(FontePadrao);
  TextoRotuloStatus.FontSize(TamanhoFontePadrao);
  TextoRotuloStatus.Color(CorFontePadrao);
  TextoRotuloStatus.Text("Status");
  
  TextoStatus.Create(0, "TextoStatus", 0, PainelStatusRotulo.Right() + EspacamentoComponentes, PainelStatus.Top() + 5, PainelStatus.Right() - EspacamentoComponentes, PainelStatus.Bottom());
  TextoStatus.Font(FontePadrao);
  TextoStatus.FontSize(TamanhoFontePadrao);
  TextoStatus.Color(CorFonteAzul);
  TextoStatus.Text("Carregando...");
  
  //Paineis dos Pares
  CPar *Par = Pares.GetFirstNode();
    
  int i = 0;
  
  for (int Linha = 0; Linha < QuantidadeLinhas; Linha++) {
    for (int Coluna = 0; Coluna < QuantidadeColunas; Coluna++) {
      if (Par == NULL)
        break;
      
      CInterfacePar *InterfacePar = new CInterfacePar(Par.NumeroMagico);
      
      InterfacePar.PainelPar.Create(0, "PainelPar" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + AlturaPainelPar + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.PainelPar.ColorBorder(CorTituloComponente);
      InterfacePar.PainelPar.ColorBackground(CorFundoComponente);
      
      InterfacePar.PainelParTitulo.Create(0, "PainelParTitulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 30 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.PainelParTitulo.ColorBackground(CorTituloComponente);
      
      InterfacePar.TextoPar.Create(0, "TextoPar" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + (LarguraPainelPar / 2) + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 5 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 30 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.TextoPar.Font(FontePadrao);
      InterfacePar.TextoPar.FontSize(TamanhoFontePadrao);
      InterfacePar.TextoPar.Color(CorFontePadrao);
      InterfacePar.TextoPar.Text(Par.AtivoCompra + " vs " + Par.AtivoVenda);
      ObjectSetInteger(0, "TextoPar" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_UPPER);
      
      InterfacePar.StatusParRotulo.Create(0, "StatusParRotulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 35 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.StatusParRotulo.Font(FontePadrao);
      InterfacePar.StatusParRotulo.FontSize(TamanhoFontePadrao);
      InterfacePar.StatusParRotulo.Color(CorFontePadrao);
      InterfacePar.StatusParRotulo.Text("Status");
      
      InterfacePar.StatusPar.Create(0, "StatusPar" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + 165 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 35 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.StatusPar.Font(FontePadrao);
      InterfacePar.StatusPar.FontSize(TamanhoFontePadrao);
      InterfacePar.StatusPar.Color(CorFonteAzul);
      InterfacePar.StatusPar.Text("...");
      ObjectSetInteger(0, "StatusPar" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      
      InterfacePar.BandaSuperiorRotulo.Create(0, "BandaSuperiorRotulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 55 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.BandaSuperiorRotulo.Font(FontePadrao);
      InterfacePar.BandaSuperiorRotulo.FontSize(TamanhoFontePadrao);
      InterfacePar.BandaSuperiorRotulo.Color(CorFontePadrao);
      InterfacePar.BandaSuperiorRotulo.Text("Banda Superior");
      
      InterfacePar.BandaSuperior.Create(0, "BandaSuperior" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + 165 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 55 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.BandaSuperior.Font(FontePadrao);
      InterfacePar.BandaSuperior.FontSize(TamanhoFontePadrao);
      InterfacePar.BandaSuperior.Color(CorFonteAzul);
      InterfacePar.BandaSuperior.Text("...");
      ObjectSetInteger(0, "BandaSuperior" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      
      InterfacePar.MediaMovelRotulo.Create(0, "MediaMovelRotulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 75 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.MediaMovelRotulo.Font(FontePadrao);
      InterfacePar.MediaMovelRotulo.FontSize(TamanhoFontePadrao);
      InterfacePar.MediaMovelRotulo.Color(CorFontePadrao);
      InterfacePar.MediaMovelRotulo.Text("Média Móvel");
      
      InterfacePar.MediaMovel.Create(0, "MediaMovel" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + 165 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 75 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.MediaMovel.Font(FontePadrao);
      InterfacePar.MediaMovel.FontSize(TamanhoFontePadrao);
      InterfacePar.MediaMovel.Color(CorFonteAzul);
      InterfacePar.MediaMovel.Text("...");
      ObjectSetInteger(0, "MediaMovel" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      
      InterfacePar.BandaInferiorRotulo.Create(0, "BandaInferiorRotulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 95 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.BandaInferiorRotulo.Font(FontePadrao);
      InterfacePar.BandaInferiorRotulo.FontSize(TamanhoFontePadrao);
      InterfacePar.BandaInferiorRotulo.Color(CorFontePadrao);
      InterfacePar.BandaInferiorRotulo.Text("Banda Inferior");
      
      InterfacePar.BandaInferior.Create(0, "BandaInferior" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + 165 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 95 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.BandaInferior.Font(FontePadrao);
      InterfacePar.BandaInferior.FontSize(TamanhoFontePadrao);
      InterfacePar.BandaInferior.Color(CorFonteAzul);
      InterfacePar.BandaInferior.Text("...");
      ObjectSetInteger(0, "BandaInferior" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      
      InterfacePar.PrecoCompraRotulo.Create(0, "PrecoCompraRotulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 115 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.PrecoCompraRotulo.Font(FontePadrao);
      InterfacePar.PrecoCompraRotulo.FontSize(TamanhoFontePadrao);
      InterfacePar.PrecoCompraRotulo.Color(CorFontePadrao);
      InterfacePar.PrecoCompraRotulo.Text("Preço de Compra");
      
      InterfacePar.PrecoCompra.Create(0, "PrecoCompra" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + 165 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 115 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.PrecoCompra.Font(FontePadrao);
      InterfacePar.PrecoCompra.FontSize(TamanhoFontePadrao);
      InterfacePar.PrecoCompra.Color(CorFonteAzul);
      InterfacePar.PrecoCompra.Text("...");
      ObjectSetInteger(0, "PrecoCompra" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      
      InterfacePar.PrecoVendaRotulo.Create(0, "PrecoVendaRotulo" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 135 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.PrecoVendaRotulo.Font(FontePadrao);
      InterfacePar.PrecoVendaRotulo.FontSize(TamanhoFontePadrao);
      InterfacePar.PrecoVendaRotulo.Color(CorFontePadrao);
      InterfacePar.PrecoVendaRotulo.Text("Preço de Venda");
      
      InterfacePar.PrecoVenda.Create(0, "PrecoVenda" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + EspacamentoComponentes + 165 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 135 + ((EspacamentoComponentes + AlturaPainelPar) * Linha), PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), PainelStatus.Bottom() + EspacamentoComponentes + 20 + ((EspacamentoComponentes + AlturaPainelPar) * Linha));
      InterfacePar.PrecoVenda.Font(FontePadrao);
      InterfacePar.PrecoVenda.FontSize(TamanhoFontePadrao);
      InterfacePar.PrecoVenda.Color(CorFonteAzul);
      InterfacePar.PrecoVenda.Text("...");
      ObjectSetInteger(0, "PrecoVenda" + IntegerToString(i), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      
      
      //Barra de Status do Ativo Sintético
      int TopoBarra = PainelStatus.Bottom() + EspacamentoComponentes  + 33 + ((EspacamentoComponentes + AlturaPainelPar) * Linha);
      int FundoBarra = PainelStatus.Bottom() + EspacamentoComponentes + AlturaPainelPar - 4 + ((EspacamentoComponentes + AlturaPainelPar) * Linha);
      int MeioBarra = (TopoBarra + FundoBarra) / 2;
      
      InterfacePar.BarraParPreco.Create(0, "BarraParPreco" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 15 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), MeioBarra - 5, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 4 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), MeioBarra + 6);
      InterfacePar.BarraParPreco.ColorBackground(CorFundoPreco);

      InterfacePar.BarraPar.Create(0, "BarraPar" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 15 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), TopoBarra, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 5 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), FundoBarra);
      InterfacePar.BarraPar.ColorBorder(CorTituloComponente);
      
      InterfacePar.BarraParBandaSuperior.Create(0, "BarraParBandaSuperior" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 15 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), TopoBarra + 20, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 5 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), TopoBarra + 21);
      InterfacePar.BarraParBandaSuperior.ColorBackground(CorTituloComponente);

      InterfacePar.BarraParMediaMovel.Create(0, "BarraParMediaMovel" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 15 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), MeioBarra, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 5 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), MeioBarra + 1);
      InterfacePar.BarraParMediaMovel.ColorBackground(CorTituloComponente);

      InterfacePar.BarraParBandaInferior.Create(0, "BarraParBandaInferior" + IntegerToString(i), 0, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 15 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), FundoBarra - 20, PainelPrincipal.Left() + EspacamentoComponentes + LarguraPainelPar - 5 + ((EspacamentoComponentes + LarguraPainelPar) * Coluna), FundoBarra - 19);
      InterfacePar.BarraParBandaInferior.ColorBackground(CorTituloComponente);
      
      
      InterfacePares.Add(InterfacePar);
      
      Par = Pares.GetNextNode();
      i++;
    }
  }
}

void CInterface::DestruirInterface() {
  PainelPrincipal.Destroy();
  PainelTitulo.Destroy();
  TextoTitulo.Destroy();
  TextoVersao.Destroy();
  PainelStatus.Destroy();
  PainelStatusRotulo.Destroy();
  TextoRotuloStatus.Destroy();
  TextoStatus.Destroy();
  BotaoDesativar.Destroy();
  
  CInterfacePar *InterfacePar = InterfacePares.GetFirstNode();
  
  while (InterfacePar != NULL) {
    InterfacePar.PainelPar.Destroy();
    InterfacePar.PainelParTitulo.Destroy();
    InterfacePar.TextoPar.Destroy();
    InterfacePar.StatusParRotulo.Destroy();
    InterfacePar.StatusPar.Destroy();
    InterfacePar.BandaSuperiorRotulo.Destroy();
    InterfacePar.BandaSuperior.Destroy();
    InterfacePar.MediaMovelRotulo.Destroy();
    InterfacePar.MediaMovel.Destroy();
    InterfacePar.BandaInferiorRotulo.Destroy();
    InterfacePar.BandaInferior.Destroy();
    InterfacePar.PrecoCompraRotulo.Destroy();
    InterfacePar.PrecoCompra.Destroy();
    InterfacePar.PrecoVendaRotulo.Destroy();
    InterfacePar.PrecoVenda.Destroy();
    InterfacePar.AlvoRotulo.Destroy();
    
    InterfacePar.BarraPar.Destroy();
    InterfacePar.BarraParBandaSuperior.Destroy();
    InterfacePar.BarraParMediaMovel.Destroy();
    InterfacePar.BarraParBandaInferior.Destroy();
    InterfacePar.BarraParPreco.Destroy();
    
    InterfacePar = InterfacePares.GetNextNode();
  }
  
  delete InterfacePares;
}


void CInterface::AtualizarInterface() {
  
  if (Robo.GetStatus() == Ativo) {
    if (CPar::GetQuantidadeOperacoes() >= Robo.GetQuantidadeOperacoesSimultaneas()) {
      if (TextoStatus.Text() != "Ativo (Limite de Operações Simultâneas Atingido)") {
        TextoStatus.Text("Ativo (Limite de Operações Simultâneas Atingido)");
      }
    } else {
      if (TextoStatus.Text() != "Ativo") {
        TextoStatus.Text("Ativo");
      }
    }
    PainelStatus.ColorBackground(CorFundoComponente);
  } else {
    if (TextoStatus.Text() != "Fora do Horario de Operação") {
      TextoStatus.Text("Fora do Horario de Operação");
    }
    PainelStatus.ColorBackground(CorFundoComponenteInativo);
  }
  
  CInterfacePar *InterfacePar = InterfacePares.GetFirstNode();
  
  while (InterfacePar != NULL) {
    CPar *Par = CPar::ParPorNumeroMagico(InterfacePar.NumeroMagico);
    
    if (Par.Status == Pronto) {
      if (Par.AtivoCompraEmLeilao || Par.AtivoVendaEmLeilao) {
        if (InterfacePar.StatusPar.Text() != "Em Leilão") {
          InterfacePar.StatusPar.Text("Em Leilão");
        }
      } else {
        if (Par.BuscandoLiquidez) {
          if (InterfacePar.StatusPar.Text() != "Buscando Liquidez")
            InterfacePar.StatusPar.Text("Buscando Liquidez");
        } else {
          if (InterfacePar.StatusPar.Text() != "Aguardando Sinal") {
            InterfacePar.StatusPar.Text("Aguardando Sinal");
          }
        }
      }
      
      if (InterfacePar.PainelPar.ColorBackground() != CorFundoComponente)
        InterfacePar.PainelPar.ColorBackground(CorFundoComponente);
    } else if (Par.Status == Comprado) {
      if (Par.AtivoCompraEmLeilao || Par.AtivoVendaEmLeilao) {
        if (InterfacePar.StatusPar.Text() != "Comprado (Leilão)")
          InterfacePar.StatusPar.Text("Comprado (Leilão)");
      } else {
        if (Par.BuscandoLiquidez) {
          if (InterfacePar.StatusPar.Text() != "Buscando Liquidez")
            InterfacePar.StatusPar.Text("Buscando Liquidez");
        } else {
          if (InterfacePar.StatusPar.Text() != "Comprado")
            InterfacePar.StatusPar.Text("Comprado");
        }
      }
      
      if (InterfacePar.PainelPar.ColorBackground() != CorFundoNegociando)
        InterfacePar.PainelPar.ColorBackground(CorFundoNegociando);
    } else if (Par.Status == Vendido) {
      if (Par.AtivoCompraEmLeilao || Par.AtivoVendaEmLeilao) {
        if (InterfacePar.StatusPar.Text() != "Vendido (Leilão)")
          InterfacePar.StatusPar.Text("Vendido (Leilão)");
      } else {
        if (Par.BuscandoLiquidez) {
          if (InterfacePar.StatusPar.Text() != "Buscando Liquidez")
            InterfacePar.StatusPar.Text("Buscando Liquidez");
        } else {
          if (InterfacePar.StatusPar.Text() != "Vendido")
            InterfacePar.StatusPar.Text("Vendido");
        }
      }
      
      if (InterfacePar.PainelPar.ColorBackground() != CorFundoNegociando)
        InterfacePar.PainelPar.ColorBackground(CorFundoNegociando);
    } else {
      if (InterfacePar.StatusPar.Text() != "Pausado")
        InterfacePar.StatusPar.Text("Pausado");
      
      if (InterfacePar.PainelPar.ColorBackground() != CorFundoComponenteInativo)
        InterfacePar.PainelPar.ColorBackground(CorFundoComponenteInativo);
    }
    
    double BandaSuperior = Par.MediaMovelSintetica + (Par.DesvioPadraoSintetico * Par.DesviosPadraoEntrada);
    double BandaInferior = Par.MediaMovelSintetica - (Par.DesvioPadraoSintetico * Par.DesviosPadraoEntrada);
    
    if (InterfacePar.BandaSuperior.Text() != DoubleToString(BandaSuperior, 5)) {
      InterfacePar.BandaSuperior.Text(DoubleToString(BandaSuperior, 5));
    }
    
    double Alvo = 0;
    
    if (Par.Status == Comprado)
      Alvo = Par.MediaMovelSintetica - (Par.DesvioPadraoSintetico * Par.DesviosPadraoSaida);
    
    if (Par.Status == Vendido)
      Alvo = Par.MediaMovelSintetica + (Par.DesvioPadraoSintetico * Par.DesviosPadraoSaida);

    if (Par.Status == Comprado || Par.Status == Vendido) {
      if (InterfacePar.MediaMovelRotulo.Text() != "Alvo") {
        InterfacePar.MediaMovelRotulo.Text("Alvo");
      }

      if (InterfacePar.MediaMovel.Text() != DoubleToString(Alvo, 5)) {
        InterfacePar.MediaMovel.Text(DoubleToString(Alvo, 5));
      }
    } else {
      if (InterfacePar.MediaMovelRotulo.Text() != "Média Móvel") {
        InterfacePar.MediaMovelRotulo.Text("Média Móvel");
      }

      if (InterfacePar.MediaMovel.Text() != DoubleToString(Par.MediaMovelSintetica, 5)) {
        InterfacePar.MediaMovel.Text(DoubleToString(Par.MediaMovelSintetica, 5));
      }
    }
    
    if (InterfacePar.BandaInferior.Text() != DoubleToString(BandaInferior, 5)) {
      InterfacePar.BandaInferior.Text(DoubleToString(BandaInferior, 5));
    }
    
    if (InterfacePar.PrecoCompra.Text() != DoubleToString(Par.PrecoCompraSintetico, 5)) {
      InterfacePar.PrecoCompra.Text(DoubleToString(Par.PrecoCompraSintetico, 5));
    }
    
    if (InterfacePar.PrecoVenda.Text() != DoubleToString(Par.PrecoVendaSintetico, 5)) {
      InterfacePar.PrecoVenda.Text(DoubleToString(Par.PrecoVendaSintetico, 5));
    }
    
    
    //Paineis de Feedback Visual
    double TopoPainel = 0;
    double FundoPainel = 0;
    
    TopoPainel = BandaSuperior + ((BandaSuperior - BandaInferior) * 0.16);
    
    if (TopoPainel < Par.PrecoCompraSintetico)
      TopoPainel = Par.PrecoCompraSintetico;
    
    FundoPainel = BandaInferior - ((BandaSuperior - BandaInferior) * 0.16);
    
    if (FundoPainel > Par.PrecoVendaSintetico)
      FundoPainel = Par.PrecoVendaSintetico;
    
    double TamanhoBarraPreco = TopoPainel - FundoPainel;
    
    int TamanhoBarraPixels = InterfacePar.BarraPar.Bottom() - InterfacePar.BarraPar.Top();
    
    //TamanhoBarraPixels TamanhoBarraPreco
    //x                  y
    
    int BandaSuperiorPixel = (int)round((TamanhoBarraPixels * (BandaSuperior - FundoPainel)) / TamanhoBarraPreco);
    int MediaMovelPixel = (int)round((TamanhoBarraPixels * (Par.MediaMovelSintetica - FundoPainel)) / TamanhoBarraPreco);
    int BandaInferiorPixel = (int)round((TamanhoBarraPixels * (BandaInferior - FundoPainel)) / TamanhoBarraPreco);
    int PrecoCompraPixel = (int)round((TamanhoBarraPixels * (Par.PrecoCompraSintetico - FundoPainel)) / TamanhoBarraPreco);
    int PrecoVendaPixel = (int)round((TamanhoBarraPixels * (Par.PrecoVendaSintetico - FundoPainel)) / TamanhoBarraPreco);
    int AlvoPixel = (int)round((TamanhoBarraPixels * (Alvo - FundoPainel)) / TamanhoBarraPreco);
    
    if (InterfacePar.BarraParBandaSuperior.Top() != InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - BandaSuperiorPixel))
      ObjectSetInteger(0, "BarraParBandaSuperior" + IntegerToString(InterfacePares.IndexOf(InterfacePar)), OBJPROP_YDISTANCE, InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - BandaSuperiorPixel));
    
    if (Par.Status == Comprado || Par.Status == Vendido) {
      if (InterfacePar.BarraParMediaMovel.Top() != InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - AlvoPixel))
        ObjectSetInteger(0, "BarraParMediaMovel" + IntegerToString(InterfacePares.IndexOf(InterfacePar)), OBJPROP_YDISTANCE, InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - AlvoPixel));
    } else {
      if (InterfacePar.BarraParMediaMovel.Top() != InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - MediaMovelPixel))
        ObjectSetInteger(0, "BarraParMediaMovel" + IntegerToString(InterfacePares.IndexOf(InterfacePar)), OBJPROP_YDISTANCE, InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - MediaMovelPixel));
    }
    
    if (InterfacePar.BarraParBandaInferior.Top() != InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - BandaInferiorPixel))
      ObjectSetInteger(0, "BarraParBandaInferior" + IntegerToString(InterfacePares.IndexOf(InterfacePar)), OBJPROP_YDISTANCE, InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - BandaInferiorPixel));
    
    if (InterfacePar.BarraParPreco.Top() != InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - PrecoCompraPixel))
      ObjectSetInteger(0, "BarraParPreco" + IntegerToString(InterfacePares.IndexOf(InterfacePar)), OBJPROP_YDISTANCE, InterfacePar.BarraPar.Top() + (TamanhoBarraPixels - PrecoCompraPixel));
    
    int AlturaPreco = PrecoCompraPixel - PrecoVendaPixel;
    
    if (AlturaPreco < 1)
      AlturaPreco = 1;
    
    if (InterfacePar.BarraParPreco.Bottom() != PrecoVendaPixel)
      ObjectSetInteger(0, "BarraParPreco" + IntegerToString(InterfacePares.IndexOf(InterfacePar)), OBJPROP_YSIZE, AlturaPreco);
    
    
    InterfacePar = InterfacePares.GetNextNode();
  }
}