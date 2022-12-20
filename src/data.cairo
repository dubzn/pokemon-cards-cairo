
%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.alloc import alloc

struct Pokemon {
    name: felt,
    type: felt, 
    artist: felt,
    id: felt,
}

func lookup_pkmn(index: felt) -> Pokemon* {
    let (addr) = get_label_location(data_start);
    return cast(addr + ((index - 1) * 4), Pokemon*);

    data_start:
    dw 'Alakazam';      
    dw 'Psychic';
    dw 'Ken Sugimori';
    dw '1';

    dw 'Blastoise';     
    dw 'Water';
    dw 'Ken Sugimori';   
    dw '2';   

    dw 'Chansey';
    dw 'Colorless'; 
    dw 'Ken Sugimori';
    dw '3';

    dw 'Charizard';     
    dw 'Fire';
    dw 'Mitsuhiro Arita';
    dw '4';       

    dw 'Clefairy';
    dw 'Colorless';
    dw 'Ken Sugimori';
    dw '5';

    dw 'Gyarados';
    dw 'Water'; 
    dw 'Mitsuhiro Arita';
    dw '6';

    dw 'Hitmonchan';       
    dw 'Fighting';
    dw 'Ken Sugimori'; 
    dw '7';  

    dw 'Machamp';
    dw 'Fighting';       
    dw 'Ken Sugimori';
    dw '8';

    dw 'Magneton';    
    dw 'Lightning';
    dw 'Keiji Kinebuchi';  
    dw '9';

    dw 'Mewtwo';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    dw '10';

    dw 'Nidoking';        
    dw 'Grass';
    dw 'Ken Sugimori';
    dw '11';

    dw 'Ninetales';
    dw 'Fire';      
    dw 'Ken Sugimori';
    dw '12';

    dw 'Poliwrath';        
    dw 'Water';
    dw 'Ken Sugimori'; 
    dw '13';    

    dw 'Raichu';
    dw 'Lightning';       
    dw 'Ken Sugimori';
    dw '14';

    dw 'Venusaur';      
    dw 'Grass';
    dw 'Mitsuhiro Arita';  
    dw '15';  

    dw 'Zapdos';
    dw 'Lightning';       
    dw 'Ken Sugimori';
    dw '16';

    dw 'Beedrill';       
    dw 'Grass';
    dw 'Ken Sugimori';  
    dw '17';

    dw 'Dragonair';
    dw 'Colorless';     
    dw 'Mitsuhiro Arita';
    dw '18';

    dw 'Dugtrio';     
    dw 'Fighting';
    dw 'Keiji Kinebuchi';
    dw '19';      

    dw 'Electabuzz';
    dw 'Lightning';      
    dw 'Ken Sugimori';
    dw '20';

    dw 'Electrode';
    dw 'Lightning';      
    dw 'Keiji Kinebuchi';
    dw '21';
    
    dw 'Pidgeotto';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    dw '22';
    
    dw 'Arcanine';
    dw 'Fire';      
    dw 'Ken Sugimori';
    dw '23';
    
    dw 'Charmeleon';
    dw 'Fire';      
    dw 'Mitsuhiro Arita';
    dw '24';
    
    dw 'Dewgong';
    dw 'Water';      
    dw 'Mitsuhiro Arita';
    dw '25';
    
    dw 'Dratini';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    dw '26';
    
    dw 'Farfetchd';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    dw '27';
    
    dw 'Growlithe';
    dw 'Fire';      
    dw 'Ken Sugimori';
    dw '28';
    
    dw 'Haunter';
    dw 'Psychic';      
    dw 'Keiji Kinebuchi';
    dw '29';
    
    dw 'Ivysaur';
    dw 'Grass';      
    dw 'Ken Sugimori';
    dw '30';
    
    dw 'Jynx';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    dw '31';
    
    dw 'Kadabra';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    dw '32';
    
    dw 'Kakuna';
    dw 'Grass';      
    dw 'Keiji Kinebuchi';
    dw '33';
    
    dw 'Machoke';
    dw 'Fighting';      
    dw 'Ken Sugimori';
    dw '34';
    
    dw 'Magikarp';
    dw 'Water';      
    dw 'Mitsuhiro Arita';
    dw '35';
    
    dw 'Magmar';
    dw 'Fire';      
    dw 'Ken Sugimori';
    dw '36';
    
    dw 'Nidorino';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    dw '37';
    
    dw 'Poliwhirl';
    dw 'Water';      
    dw 'Ken Sugimori';
    dw '38';
    
    dw 'Porygon';
    dw 'Colorless';      
    dw 'Tomoaki Imakuni';
    dw '39';
    
    dw 'Raticate';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    dw '40';
    
    dw 'Seel';
    dw 'Water';      
    dw 'Ken Sugimori';
    dw '41';
    
    dw 'Wartortle';
    dw 'Water';      
    dw 'Ken Sugimori';
    dw '42';
    
    dw 'Abra';
    dw 'Psychic';      
    dw 'Mitsuhiro Arita';
    dw '43';
    
    dw 'Bulbasaur';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    dw '44';
    
    dw 'Caterpie';
    dw 'Grass';      
    dw 'Ken Sugimori';
    dw '45';
    
    dw 'Charmander';
    dw 'Fire';      
    dw 'Mitsuhiro Arita';
    dw '46';
    
    dw 'Diglett';
    dw 'Fighting';      
    dw 'Keiji Kinebuchi';
    dw '47';
    
    dw 'Doduo';
    dw 'Colorless';      
    dw 'Mitsuhiro Arita';
    dw '48';
    
    dw 'Drowzee';
    dw 'Psychic';      
    dw 'Ken Sugimori';
    dw '49';
    
    dw 'Gastly';
    dw 'Psychic';      
    dw 'Keiji Kinebuchi';
    dw '50';
    
    dw 'Koffing';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    dw '51';
    
    dw 'Machop';
    dw 'Fighting';      
    dw 'Mitsuhiro Arita';
    dw '52';
    
    dw 'Magnemite';
    dw 'Lightning';      
    dw 'Keiji Kinebuchi';
    dw '53';
    
    dw 'Metapod';
    dw 'Grass';      
    dw 'Ken Sugimori';
    dw '54';
    
    dw 'Nidoran M';
    dw 'Grass';      
    dw 'Ken Sugimori';
    dw '55';
    
    dw 'Onix';
    dw 'Fighting';      
    dw 'Ken Sugimori';
    dw '56';
    
    dw 'Pidgey';
    dw 'Colorless';      
    dw 'Ken Sugimori';
    dw '57';
    
    dw 'Pikachu';
    dw 'Lightning';      
    dw 'Mitsuhiro Arita';
    dw '58';
    
    dw 'Poliwag';
    dw 'Water';      
    dw 'Ken Sugimori';
    dw '59';
    
    dw 'Ponyta';
    dw 'Fire';      
    dw 'Ken Sugimori';
    dw '60';
    
    dw 'Rattata';
    dw 'Colorless';      
    dw 'Mitsuhiro Arita';
    dw '61';
    
    dw 'Sandshrew';
    dw 'Fighting';      
    dw 'Ken Sugimori';
    dw '62';
    
    dw 'Squirtle';
    dw 'Water';      
    dw 'Mitsuhiro Arita';
    dw '63';
    
    dw 'Starmie';
    dw 'Water';      
    dw 'Keiji Kinebuchi';
    dw '64';
    
    dw 'Staryu';
    dw 'Water';      
    dw 'Keiji Kinebuchi';
    dw '65';
    
    dw 'Tangela';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    dw '66';
    
    dw 'Voltorb';
    dw 'Lightning';      
    dw 'Keiji Kinebuchi';
    dw '67';
    
    dw 'Vulpix';
    dw 'Fire';      
    dw 'Ken Sugimori';
    dw '68';
    
    dw 'Weedle';
    dw 'Grass';      
    dw 'Mitsuhiro Arita';
    dw '69';
}
