defmodule Ale8583Test do
  use ExUnit.Case
  doctest Ale8583
  require Logger 

  test "list to iso type :prosa" do
    listRAW='ISO0060000400800822000000000000004000000000000000804180203010449101'
    strHeadProsa=Enum.take(listRAW,12) |> List.to_string #String.slice(data,0,12)
    Logger.debug "Header PROSA : #{strHeadProsa} "
    ## MTI
    strMTI= Enum.slice(listRAW, 12 ,4 ) |> List.to_string
    ## BIT MAP PRIMARY
    strBitMap=Enum.slice(listRAW, 16,16 ) |> List.to_string
    ## BIT MAP IF TRANSACTION HAS BIT MAP SECONDARY
    strBitMap =
    if Ale8583.haveBitMapSec?(strBitMap) == true do
      Enum.slice(listRAW,16,32) |> List.to_string
    else
      strBitMap
    end
    
    ## TAKE FIELDS SINCE FIELD 1.  
    listFields= Enum.take(listRAW, 32 - Kernel.length(listRAW))

    ## ISO MAKES FROM MTI AND CONFIGURATION FILE.
    isoMTI=Ale8583.new_with_out_conf({strMTI,"/Users/ale/testPrograms/ale8583/ale8583/ascii.iso.cfg"})
    {:iso,listISO,{listBitMapP,listBitMapS,flagBMSec,listISOconf},{status, message}} = isoMTI
    Logger.info "Result : #{inspect status} #{inspect message}" 
    assert status == :ok
    #Logger.info "#{inspect isoMTI} "
    Logger.info "#{inspect strBitMap}, #{inspect listFields}, #{inspect strHeadProsa} "
    isoMTI= Ale8583.list_to_iso({strBitMap,listFields, :prosa ,strHeadProsa}, isoMTI)
    {:iso,listISO,{listBitMapP,listBitMapS,flagBMSec,listISOconf},{status, message}} = isoMTI
    ## INSPECT RESULT :ok or :error
    Logger.info "Result : #{inspect status} #{inspect message}" 
    assert status == :ok

    Ale8583.printAll(isoMTI, "Print fields ISO type #{strMTI}:")
    
    # VALIDATE FIELDS CONTENT 
    assert List.keymember?(listISO, :c1, 0) == true
    assert List.keymember?(listISO, :c7, 0) == true
    assert List.keymember?(listISO, :c11, 0) == true
    assert List.keymember?(listISO, :c70, 0) == true
    #{ _ , strC3 } = List.keyfind( listISO , :c3 ,0)
    #assert "111000" == strC3
    { _ , strBMP } = List.keyfind( listISO , :bp ,0)
    assert "8220000000000000" == strBMP
    Logger.info "Result : #{inspect status} #{inspect message}"
    assert status == :ok
  end

  test "ISO type :prosa makes" do
  #test "list to iso 2" do
    iso0800=Ale8583.new_with_out_conf({"0800","/Users/ale/testPrograms/ale8583/ale8583/ascii.iso.cfg"},"ISO000000000")
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok 

    iso0800=Ale8583.addField({7,"0207181112"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok

    iso0800=Ale8583.addField({11,"123456"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok

    
    iso0800=Ale8583.addField({70,"001"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok


    assert Ale8583.haveInISO?(iso0800, :bs) == true
    assert Ale8583.haveInISO?(iso0800, :c7) == true
    assert Ale8583.haveInISO?(iso0800, :c11) == true
    assert Ale8583.haveInISO?(iso0800, :c70) == true

    {_,listISO,{ bitMapP,bitMapS,flagBMSec,isoConf },{ status, message} } = iso0800
    
    assert List.keymember?(listISO, :c7, 0) == true
    { _ , strC7 } = List.keyfind( listISO , :c7 ,0)
    assert "0207181112" == strC7

    assert List.keymember?(listISO, :c11, 0) == true
    { _ , strC11 } = List.keyfind( listISO , :c11 ,0)
    assert "123456" == strC11
    
    assert List.keymember?(listISO, :c70, 0) == true
    { _ , strC70 } = List.keyfind( listISO , :c70 ,0)
    assert "001" == strC70
    trama0800=Ale8583.getTrama(iso0800)
    assert trama0800 == 'ISO0000000000800822000000000000004000000000000000207181112123456001'
    Logger.info  "Trama PROSA ready for socket: <#{inspect trama0800}>"
 
  end
  test "list to iso type :master_card" do
    listRAW='ðøðð            ðððððððððððñòðööñðùðððððñôô÷ðöñðÂð@@@@ðððððððð'
    ## MTI
    strMTI= Enum.slice(listRAW, 0 ,4 ) |> Ale8583.Convert.ebcdic_to_ascii |> List.to_string
    ## BIT MAP PRIMARY , format bynary only 8 bytes 
    strBitMap=Enum.slice(listRAW, 4 , 8 ) |> Ale8583.Convert.bin_to_ascii |> List.to_string
    ## BIT MAP IF TRANSACTION HAS BIT MAP SECONDARY
    strBitMap =
    if Ale8583.haveBitMapSec?(strBitMap) == true do
      Enum.slice(listRAW,4,16) |> Ale8583.Convert.bin_to_ascii |> List.to_string
    else
      strBitMap
    end
    ## TAKE FIELDS SINCE FIELD 1.  
    listFields = Enum.take(listRAW, 20 - Kernel.length(listRAW))

    ## ISO MAKES FROM MTI AND CONFIGURATION FILE.
    isoMTI=Ale8583.new_with_out_conf({strMTI,"/Users/ale/testPrograms/ale8583/ale8583/ebcdic.iso.cfg"})
    {:iso,listISO,{listBitMapP,listBitMapS,flagBMSec,listISOconf},{status, message}} = isoMTI
    Logger.info "Result : #{inspect status} #{inspect message}" 
    assert status == :ok
    #Logger.info "#{inspect isoMTI} "
    Logger.info " #{inspect listFields}, #{inspect strMTI} "
    isoMTI= Ale8583.list_to_iso({strBitMap,listFields, :master_card ,""}, isoMTI)
    {:iso,listISO,{listBitMapP,listBitMapS,flagBMSec,listISOconf},{status, message}} = isoMTI
    ## INSPECT RESULT :ok or :error
    Logger.info "Result : #{inspect status} #{inspect message}" 
    assert status == :ok

    Ale8583.printAll(isoMTI, "Print fields ISO type #{strMTI}:")
    
    # VALIDATE FIELDS CONTENT 
    assert List.keymember?(listISO, :bs, 0) == true
    assert List.keymember?(listISO, :c7, 0) == true
    assert List.keymember?(listISO, :c33, 0) == true
    assert List.keymember?(listISO, :c70, 0) == true
    assert List.keymember?(listISO, :c94, 0) == true
    assert List.keymember?(listISO, :c96, 0) == true
    #{ _ , strC3 } = List.keyfind( listISO , :c3 ,0)
    #assert "111000" == strC3
    { _ , strBMP } = List.keyfind( listISO , :bp ,0)
    assert "8220000080000000" == strBMP
    assert status == :ok

    { _ , strBMS } = List.keyfind( listISO , :bs ,0)
    assert "0400000500000000" == strBMS
    assert status == :ok

  end

  test "ISO type :master_card makes" do
  #test "ISO type :prosa makes" do
    iso0800=Ale8583.new_with_out_conf({"0800","/Users/ale/testPrograms/ale8583/ale8583/ebcdic.iso.cfg"})
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok 

    iso0800=Ale8583.addField({7,"0207181112"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok

    iso0800=Ale8583.addField({11,"123456"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok

    iso0800=Ale8583.addField({33,"900000144"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok
    
    iso0800=Ale8583.addField({70,"061"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok

    iso0800=Ale8583.addField({96,"00000000"},iso0800)
    status=:error
    {:iso,_,{ _,_,_,_ },{ status, _} } = iso0800
    assert status == :ok


    assert Ale8583.haveInISO?(iso0800, :bs) == true
    assert Ale8583.haveInISO?(iso0800, :c7) == true
    assert Ale8583.haveInISO?(iso0800, :c11) == true
    assert Ale8583.haveInISO?(iso0800, :c33) == true
    assert Ale8583.haveInISO?(iso0800, :c70) == true
    assert Ale8583.haveInISO?(iso0800, :c96) == true

    {_,listISO,{ bitMapP,bitMapS,flagBMSec,isoConf },{ status, message} } = iso0800
    
    assert List.keymember?(listISO, :c7, 0) == true
    { _ , strC7 } = List.keyfind( listISO , :c7 ,0)
    assert "0207181112" == strC7

    assert List.keymember?(listISO, :c11, 0) == true
    { _ , strC11 } = List.keyfind( listISO , :c11 ,0)
    assert "123456" == strC11
    
    assert List.keymember?(listISO, :c70, 0) == true
    { _ , strC70 } = List.keyfind( listISO , :c70 ,0)
    assert "061" == strC70

    trama0800=Ale8583.getTrama(iso0800)
    Logger.info  "Trama MASTERCARD ready for socket: <#{inspect trama0800}>"
 
  end



end
