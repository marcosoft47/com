# Alunos: Guilherme Gamaliel Lima, Marco Antonio Reche Rigon

def first(gramatica: dict, epsilon="e") -> dict:
    naoTerminais = list(gramatica.keys())

    first = {nt: set() for nt in naoTerminais} # iniciar um dicionario de first

    mudou = True
    while mudou:
        mudou = False
        for chave, producao in gramatica.items():
            for prod in producao:
                if prod == [epsilon]: # epsilon
                    if epsilon not in first[chave]:
                        first[chave].add(epsilon)
                        mudou = True
                    continue
                for simbolo in prod:
                    if simbolo not in gramatica: # terminal
                        if simbolo not in first[chave]: # evitar dado duplicado
                            first[chave].add(simbolo)
                            mudou = True
                        break

                    adicionar = first[simbolo] - {epsilon} # não terminal
                    if not adicionar.issubset(first[chave]): # evitar dado duplicado
                        first[chave].update(adicionar)
                        mudou = True

                    if epsilon not in first[simbolo]:
                        break
                else:
                    if epsilon not in first[chave]:
                        first[chave].add(epsilon)
                        mudou = True
    return first

def follow(gramatica: dict, epsilon="e", marcadorfinal="$") -> dict:
    first_table = first(gramatica, epsilon)
    naoTerminais = list(gramatica.keys())
    follow = {nt: set() for nt in naoTerminais}

    simboloInicial = naoTerminais[0]
    follow[simboloInicial].add(marcadorfinal)

    mudou = True
    while mudou:
        mudou = False
        for chave, producao in gramatica.items():
            for prod in producao:
                for i, simbolo in enumerate(prod):
                    if simbolo not in gramatica:
                        continue

                    restante = prod[i + 1:]
                    if not restante:
                        if not follow[chave].issubset(follow[simbolo]):
                            follow[simbolo].update(follow[chave])
                            mudou = True
                        continue

                    primeiro = set()
                    for s in restante:
                        if s not in gramatica:
                            if s not in primeiro:
                                primeiro.add(s)
                            break

                        primeiro.update(first_table[s] - {epsilon})
                        if epsilon not in first_table[s]:
                            break
                    else:
                        primeiro.add(epsilon)

                    if not (primeiro - {epsilon}).issubset(follow[simbolo]):
                        follow[simbolo].update(primeiro - {epsilon})
                        mudou = True

                    if epsilon in primeiro:
                        if not follow[chave].issubset(follow[simbolo]):
                            follow[simbolo].update(follow[chave])
                            mudou = True

    return follow

if __name__ == "__main__":

    gramatica = {
    "E":  [["T", "E'"]],
    "E'": [["+", "T", "E'"], ["e"]],
    "T":  [["F", "T'"]],
    "T'": [["*", "F", "T'"], ["e"]],
    "F":  [["(", "E", ")"], ["c"]]
    }

    # gramatica = {
    #     "S": [["A", "B", "S"], ["a", "A"]],
    #     "A": [["e"], ["a"]],
    #     "B": [["B", "b"], ["c", "d"]]
    # }

    print("FIRST:")
    print(first(gramatica))
    print("\nFOLLOW:")
    print(follow(gramatica))
