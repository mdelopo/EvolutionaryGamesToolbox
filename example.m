B = [3 1; 4 2];
T = 10;
Strategies = ["All_D", "All_C", "Grim", "TitForTat", "Alternator", "SneakyTitForTat", "SpitefulTitForTat", "TwoTitsForTat", "Prober", "Detective", "TitForTwoTats","Cycler"];
Pop = [10 10 10 10 10 10 10 10 10 10 10 10];
scores = Axel(B, Strategies, Pop, T)
