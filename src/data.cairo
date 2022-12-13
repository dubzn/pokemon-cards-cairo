
%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.alloc import alloc

struct Pokemon {
    name: felt,
    type: felt, 
    artist: felt,
}

func lookup_pkmn(index: felt) -> Pokemon* {
    let (addr) = get_label_location(data_start);
    return cast(addr + ((index - 1) * 2), Pokemon*);

    data_start:
    dw 'Alakazam';      
    dw 'Psychic';
    dw 'Ken Sugimori';

    dw 'Blastoise';     
    dw 'Water';
    dw 'Ken Sugimori';      

    dw 'Chansey';
    dw 'Colorless'; 
    dw 'Ken Sugimori';

    dw 'Charizard';     
    dw 'Fire';
    dw 'Mitsuhiro Arita';       

    dw 'Clefairy';
    dw 'Colorless';
    dw 'Ken Sugimori';

    dw 'Gyarados';
    dw 'Water'; 
    dw 'Mitsuhiro Arita';

    dw 'Hitmonchan';       
    dw 'Fighting';
    dw 'Ken Sugimori';   

    dw 'Machamp';
    dw 'Fighting';       
    dw 'Ken Sugimori';

    dw 'Magneton';    
    dw 'Lightning';
    dw 'Keiji Kinebuchi';  

    dw 'Mewtwo';
    dw 'Psychic';      
    dw 'Ken Sugimori';

    dw 'Nidoking';        
    dw 'Grass';
    dw 'Ken Sugimori';

    dw 'Ninetales';
    dw 'Fire';      
    dw 'Ken Sugimori';

    dw 'Poliwrath';        
    dw 'Water';
    dw 'Ken Sugimori';     

    dw 'Raichu';
    dw 'Lightning';       
    dw 'Ken Sugimori';

    dw 'Venusaur';      
    dw 'Grass';
    dw 'Mitsuhiro Arita';    

    dw 'Zapdos';
    dw 'Lightning';       
    dw 'Ken Sugimori';

    dw 'Beedrill';       
    dw 'Grass';
    dw 'Ken Sugimori';  

    dw 'Dragonair';
    dw 'Colorless';     
    dw 'Mitsuhiro Arita';

    dw 'Dugtrio';     
    dw 'Fighting';
    dw 'Keiji Kinebuchi';      

    dw 'Electabuzz';
    dw 'Lightning';      
    dw 'Ken Sugimori';

    dw 'Electrode';
    dw 'Lightning';      
    dw 'Keiji Kinebuchi';
    
    dw 'Pidgeotto';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    
    dw 'Arcanine';
    dw 'Fire';      
    dw 'Ken Sugimori';
    
    dw 'Charmeleon';
    dw 'Fire';      
    dw 'Mitsuhiro Arita';
    
    dw 'Dewgong';
    dw 'Water';      
    dw 'Mitsuhiro Arita';
    
    dw 'Dratini';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    
    dw 'Farfetchd';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    
    dw 'Growlithe';
    dw 'Fire';      
    dw 'Ken Sugimori';
    
    dw 'Haunter';
    dw 'Psychic';      
    dw 'Keiji Kinebuchi';
    
    dw 'Ivysaur';
    dw 'Grass';      
    dw 'Ken Sugimori';
    
    dw 'Jynx';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    
    dw 'Kadabra';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    
    dw 'Kakuna';
    dw 'Grass';      
    dw 'Keiji Kinebuchi';
    
    dw 'Machoke';
    dw 'Fighting';      
    dw 'Ken Sugimori';
    
    dw 'Magikarp';
    dw 'Water';      
    dw 'Mitsuhiro Arita';
    
    dw 'Magmar';
    dw 'Fire';      
    dw 'Ken Sugimori';
    
    dw 'Nidorino';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    
    dw 'Poliwhirl';
    dw 'Water';      
    dw 'Ken Sugimori';
    
    dw 'Porygon';
    dw 'Colorless';      
    dw 'Tomoaki Imakuni';
    
    dw 'Raticate';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    
    dw 'Seel';
    dw 'Water';      
    dw 'Ken Sugimori';
    
    dw 'Wartortle';
    dw 'Water';      
    dw 'Ken Sugimori';
    
    dw 'Abra';
    dw 'Psychic';      
    dw 'Mitsuhiro Arita';
    
    dw 'Bulbasaur';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    
    dw 'Caterpie';
    dw 'Grass';      
    dw 'Ken Sugimori';
    
    dw 'Charmander';
    dw 'Fire';      
    dw 'Mitsuhiro Arita';
    
    dw 'Diglett';
    dw 'Fighting';      
    dw 'Keiji Kinebuchi';
    
    dw 'Doduo';
    dw 'Colorless';      
    dw 'Mitsuhiro Arita';
    
    dw 'Drowzee';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    
    dw 'Gastly';
    dw 'Psychic';      
    dw 'Keiji Kinebuchi';
    
    dw 'Koffing';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    
    dw 'Machop';
    dw 'Fighting';      
    dw 'Mitsuhiro Arita';
    
    dw 'Magnemite';
    dw 'Lightning';      
    dw 'Keiji Kinebuchi';
    
    dw 'Metapod';
    dw 'Grass';      
    dw 'Ken Sugimori';
    
    dw 'Nidoran M';
    dw 'Grass';      
    dw 'Ken Sugimori';
    
    dw 'Onix';
    dw 'Fighting';      
    dw 'Ken Sugimori';
    
    dw 'Pidgey';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    
    dw 'Pikachu';
    dw 'Lightning';      
    dw 'Mitsuhiro Arita';
    
    dw 'Poliwag';
    dw 'Water';      
    dw 'Ken Sugimori';
    
    dw 'Ponyta';
    dw 'Fire';      
    dw 'Ken Sugimori';
    
    dw 'Rattata';
    dw 'Colorless';      
    dw 'Mitsuhiro Arita';
    
    dw 'Sandshrew';
    dw 'Fighting';      
    dw 'Ken Sugimori';
    
    dw 'Squirtle';
    dw 'Water';      
    dw 'Mitsuhiro Arita';
    
    dw 'Starmie';
    dw 'Water';      
    dw 'Keiji Kinebuchi';
    
    dw 'Staryu';
    dw 'Water';      
    dw 'Keiji Kinebuchi';
    
    dw 'Tangela';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    
    dw 'Voltorb';
    dw 'Lightning';      
    dw 'Keiji Kinebuchi';
    
    dw 'Vulpix';
    dw 'Fire';      
    dw 'Ken Sugimori';
    
    dw 'Weedle';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
}
