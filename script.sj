//Validação
function validarProduto(
  idNomeProduto,
  idCodProduto,
  idQtidadeProduto,
  idValorProduto
) {
  let nome = document.getElementById(idNomeProduto).value;
  let codigo = document.getElementById(idCodProduto).value;
  let qtidade = document.getElementById(idQtidadeProduto).value;
  let valor = document.getElementById(idValorProduto).value;

  if (nome == "")
    alert("Nome do produto não pode estar em branco!");
  else if (codigo == "")
    alert("Código do produto não pode estar em branco!");
  else if (qtidade == "" || parseInt(qtidade) <= 0)
    alert("Quantidade inválida!");
  else if (valor == "" || isNaN(parseFloat(valor)) || parseFloat(valor) <= 0)
    alert("Valor inválido!");
  else
    cadastrarProduto(
      nome,
      codigo,
      parseInt(qtidade),
      parseFloat(valor)
    );
}

//Cadastro/Manipulação do produto
function cadastrarProduto(produto, codig, qtidade, valor) {
  
  let novoProduto = {
    nome: produto,
    codigo: codig,
    quantidade: qtidade,
    valor: valor
  };

  if (typeof(Storage) !== "undefined") {
    let produtos = localStorage.getItem("produtos");

    if (produtos == null)
      produtos = [];
    else
      produtos = JSON.parse(produtos);

    produtos.push(novoProduto);

    localStorage.setItem("produtos", JSON.stringify(produtos));

    alert(
      "Foram cadastradas com sucesso " +
      qtidade +
      " unidades do produto " +
      produto +
      " no valor de R$ " + valor.toFixed(2) + "!"
    );

    atualizarTotalEstoque("totalEstoque");
    location.reload();

  } else
    alert(
      "A versão do seu navegador é muito antiga, Por isso, não será possível executar esta aplicação"
    );
}
function editarProduto(index) {
  let produtos = JSON.parse(localStorage.getItem("produtos") || "[]");
  const produto = produtos[index];

  // pedir novos valores
  const novoNome = prompt("Digite o novo nome:", produto.nome);
  const novoCodigo = prompt("Digite o novo código:", produto.codigo);
  const novaQtde = prompt("Digite a nova quantidade:", produto.quantidade);

  if (novoNome !== null && novoCodigo !== null && novaQtde !== null) {
    produto.nome = novoNome;
    produto.codigo = novoCodigo;
    produto.quantidade = parseInt(novaQtde);

    localStorage.setItem("produtos", JSON.stringify(produtos));
    listarEstoque();
  }
}
function excluirProduto(index) {
  if (confirm("Deseja realmente excluir este produto?")) {
    let produtos = JSON.parse(localStorage.getItem("produtos") || "[]");
    produtos.splice(index, 1);
    localStorage.setItem("produtos", JSON.stringify(produtos));

    // opcional: atualizar totalEstoque
    let totalEstoque = localStorage.getItem("totalEstoque") || 0;
    totalEstoque = Math.max(0, totalEstoque - 1);
    localStorage.setItem("totalEstoque", totalEstoque);

    listarEstoque();
  }
}

//Estoque
function carregarTotalEstoque(

 idCampo) {

 if (typeof(Storage) !==

  "undefined") {

  let totalEstoque = localStorage

   .getItem("totalEstoque");

  if (totalEstoque == null)

   totalEstoque = 0;

  document.getElementById(idCampo)

   .innerHTML = totalEstoque;

 } else alert(

  "A versão do seu navegador é muito antiga, Por isso, não será possível executar essa aplicação"

 );

}
function listarEstoque() {
  if (typeof(Storage) === "undefined") {
    alert("Seu navegador é muito antigo!");
    return;
  }

  let produtos = localStorage.getItem("produtos");
  const tbody = document
    .getElementById("tabelaEstoque")
    .getElementsByTagName("tbody")[0];

  // limpa tabela
  tbody.innerHTML = "";

  // se não tiver produtos, mostra mensagem
  if (produtos == null || JSON.parse(produtos).length === 0) {
    const tr = document.createElement("tr");
    const td = document.createElement("td");
    td.colSpan = 5;
    td.textContent = "Nenhum produto no estoque";
    tr.appendChild(td);
    tbody.appendChild(tr);
    return;
  }

  produtos = JSON.parse(produtos);

  produtos.forEach((produto, index) => {
    const tr = document.createElement("tr");

    // Nome
    const tdNome = document.createElement("td");
    tdNome.textContent = produto.nome;
    tr.appendChild(tdNome);

    // Código
    const tdCodigo = document.createElement("td");
    tdCodigo.textContent = produto.codigo;
    tr.appendChild(tdCodigo);

    // Quantidade
    const tdQuantidade = document.createElement("td");
    tdQuantidade.textContent = produto.quantidade;
    tr.appendChild(tdQuantidade);

    // Valor
    const tdValor = document.createElement("td");
    tdValor.textContent = "R$ " + produto.valor.toFixed(2);
    tr.appendChild(tdValor);

    // Ações
    const tdAcoes = document.createElement("td");

    // botão Editar
    const btnEditar = document.createElement("button");
    btnEditar.textContent = "Editar";
    btnEditar.onclick = () => editarProduto(index);
    tdAcoes.appendChild(btnEditar);

    // botão Excluir
    const btnExcluir = document.createElement("button");
    btnExcluir.textContent = "Excluir";
    btnExcluir.style.marginLeft = "6px";
    btnExcluir.onclick = () => excluirProduto(index);
    tdAcoes.appendChild(btnExcluir);

    // botão Comprar (Registrar Compra)
    const btnComprar = document.createElement("button");
    btnComprar.textContent = "Comprar";
    btnComprar.style.marginLeft = "6px";
    btnComprar.onclick = () => registrarCompra(index);
    tdAcoes.appendChild(btnComprar);

    tr.appendChild(tdAcoes);

    tbody.appendChild(tr);
  });
}

//Compras
function registrarCompra(indexProduto) {
  // pega produtos e compras
  let produtos = JSON.parse(localStorage.getItem("produtos") || "[]");
  let compras  = JSON.parse(localStorage.getItem("compras")  || "[]");

  const produto = produtos[indexProduto];
  if (!produto) {
    alert("Produto não encontrado!");
    return;
  }

  // pergunta quantidade
  const qtdeCompra = parseInt(prompt("Quantidade desejada:", "1"));
  if (isNaN(qtdeCompra) || qtdeCompra <= 0) {
    alert("Quantidade inválida!");
    return;
  }

  if (qtdeCompra > produto.quantidade) {
    alert("Quantidade insuficiente no estoque!");
    return;
  }

  // pergunta cliente
  const cliente = prompt("Nome do comprador:");
  if (!cliente || cliente.trim() === "") {
    alert("Nome do comprador não foi preenchido!");
    return;
  }

  // calcula total
  const totalCompra = qtdeCompra * produto.valor;

  // adiciona ao histórico de compras
  compras.push({
    produto: produto.nome,
    quantidade: qtdeCompra,
    total: totalCompra,
    cliente: cliente
  });

  // salva compras no localStorage
  localStorage.setItem("compras", JSON.stringify(compras));

  // diminui no estoque
  produto.quantidade -= qtdeCompra;
  produtos[indexProduto] = produto;
  localStorage.setItem("produtos", JSON.stringify(produtos));

  alert(`Compra registrada com sucesso!
Produto: ${produto.nome}
Quantidade: ${qtdeCompra}
Total: R$ ${totalCompra.toFixed(2)}
Comprador: ${cliente}`);

  // atualiza as duas tabelas
  listarEstoque();
  listarCompras();
}
function excluirCompra(index) {
  if (confirm("Deseja excluir esta compra?")) {
    let compras = JSON.parse(localStorage.getItem("compras") || "[]");
    compras.splice(index, 1);
    localStorage.setItem("compras", JSON.stringify(compras));
    listarCompras();
  }
}

//Listagem de compras
function listarCompras() {
  const compras = JSON.parse(localStorage.getItem("compras") || "[]");
  const tbody = document.getElementById("tabelaCompras");
  if (!tbody) return;

  tbody.innerHTML = "";

  if (compras.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="5">Nenhuma compra registrada</td>
      </tr>
    `;
    return;
  }

  compras.forEach((compra, index) => {
    tbody.innerHTML += `
      <tr>
        <td>${compra.produto}</td>
        <td>${compra.quantidade}</td>
        <td>R$ ${compra.total.toFixed(2)}</td>
        <td>${compra.cliente}</td>
        <td>
          <button onclick="excluirCompra(${index})">Excluir</button>
        </td>
      </tr>
    `;
  });
}


//Inicialização da pág.
document.addEventListener("DOMContentLoaded", () => {
  listarEstoque();
  listarCompras();
  carregarTotalEstoque();
});


// Próxima versão:
// - forma de pagamento (à vista / parcelado)
// - edição de compras
// - múltiplos itens por cliente




