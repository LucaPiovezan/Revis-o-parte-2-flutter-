import '../services/database_service.dart';

class ImpressaoRepository {
  final DatabaseService service;
  ImpressaoRepository(this.service);

  Future<List<Map<String, Object?>>> listar() async {
    final db = await service.banco;
    return db.query('documentos', orderBy: 'id ASC');
  }

  Future<void> salvar(
      {int? id,
      required String nome,
      required int paginas,
      required int copias}) async {
    final db = await service.banco;
    final dados = <String, Object?>{
      'nome': nome.trim(),
      'paginas': paginas,
      'copias': copias,
    };
    if (id == null) {
      await db.insert('documentos', {...dados, 'impresso': 0});
    } else {
      await db.update('documentos', dados, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> alternarImpressao(int id, bool estavaImpresso) async {
    final db = await service.banco;
    final novoValor = estavaImpresso ? 0 : 1;
    await db.update('documentos', {'impresso': novoValor},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> excluir(int id) async {
    final db = await service.banco;
    await db.delete('documentos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restaurarAmostras() async {
    final db = await service.banco;
    await db.transaction((txn) async {
      await txn.delete('documentos');
      await txn.delete('sqlite_sequence',
          where: 'name = ?', whereArgs: ['documentos']);
      for (final documento in DatabaseService.amostras) {
        await txn.insert('documentos', documento);
      }
    });
  }
}
