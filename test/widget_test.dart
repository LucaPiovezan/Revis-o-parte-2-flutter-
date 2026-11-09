import 'package:flutter_test/flutter_test.dart';
import 'package:revisao/providers/impressao_provider.dart';
import 'package:revisao/repositories/impressao_repository.dart';
import 'package:revisao/services/database_service.dart';

class RepositorioFalso extends ImpressaoRepository {
  RepositorioFalso(this.documentos) : super(DatabaseService());

  final List<Map<String, Object?>> documentos;

  @override
  Future<List<Map<String, Object?>>> listar() async {
    return documentos.map((documento) => Map.of(documento)).toList();
  }

  @override
  Future<void> alternarImpressao(int id, bool estavaImpresso) async {
    final documento = documentos.firstWhere((item) => item['id'] == id);
    documento['impresso'] = estavaImpresso ? 0 : 1;
  }
}

void main() {
  final documentos = <Map<String, Object?>>[
    {
      'id': 1,
      'nome': 'Roteiro do evento',
      'paginas': 4,
      'copias': 3,
      'impresso': 0
    },
    {
      'id': 2,
      'nome': 'Cartaz da oficina',
      'paginas': 2,
      'copias': 5,
      'impresso': 0
    },
    {
      'id': 3,
      'nome': 'Lista de presença',
      'paginas': 1,
      'copias': 2,
      'impresso': 1
    },
  ];

  test('calcula folhas, filtra pendentes e altera apenas o documento escolhido',
      () async {
    final provider = ImpressaoProvider(RepositorioFalso(documentos));
    await provider.iniciar();

    expect(provider.totalDocumentos, 3);
    expect(provider.totalFolhas, 24);
    expect(provider.folhasDoDocumento(provider.documentosVisiveis.first), 12);

    provider.alterarFiltro('Pendentes');
    expect(provider.documentosVisiveis.map((item) => item['nome']), [
      'Roteiro do evento',
      'Cartaz da oficina',
    ]);

    await provider.alternar(provider.documentosVisiveis.first);
    provider.alterarFiltro('Todos');
    expect(provider.documentosVisiveis[0]['impresso'], 1);
    expect(provider.documentosVisiveis[1]['impresso'], 0);
    expect(provider.documentosVisiveis[2]['impresso'], 1);
  });

  test('recusa zero em páginas e cópias', () {
    final provider = ImpressaoProvider(RepositorioFalso(documentos));

    expect(provider.validar('Documento', 0, 1), isNotNull);
    expect(provider.validar('Documento', 1, 0), isNotNull);
  });
}
