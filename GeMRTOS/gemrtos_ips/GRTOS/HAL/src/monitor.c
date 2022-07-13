/**
 *  \file 
 *  \author Ricardo Cayssials
 *  \brief Monitor functions for debugging
 *  \details This file contains the Monitor functions for debugging.
 *  \version 0.9a
 *  \date      2015-2020
 *  \bug  Describe found bugs here.
 *  \copyright Ricardo Cayssials  (rcayssials@gmail.com)
 *  \copyright All rights reserved.
 *  \copyright Copyright (c) 2013-2020
 *  \warning This product was produced by Ricardo Cayssials in the hope that it 
 *  will be useful, but WITHOUT ANY WARRANTY; without even the implied 
 *  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 *  \warning DISCLAIMER OF WARRANTY. THIS PRODUCT IS LICENSED "AS IS." YOU BEAR THE RISK OF USING IT. 
 *  \warning RICARDO CAYSSIALS GIVES NO EXPRESS WARRANTIES, GUARANTEES, OR CONDITIONS. 
 *  TO THE EXTENT PERMITTED UNDER APPLICABLE LAWS, RICARDO CAYSSIALS EXCLUDES ALL IMPLIED WARRANTIES,
 *  INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
 */
  
/******************************************************************************
*                                                                             *
* License Agreement                                                           *
* Copyright (c) Ricardo L. Cayssials                                          *
* All rights reserved.                                                        *
*                                                                             *
******************************************************************************/


#include <grtos.h>
#include "grtosdefinitions.h"

OPTIMEZE_CODE(3)

/**gk_MONITOR_FIFO_SAMPLE
 *  \brief This function stores the data in he monitor FIFO wth the time stamp 
 *  
 *  \param [in] data Value to be stored into the FIFO
 *  \relates Monitor
 */
void gk_MONITOR_FIFO_SAMPLE (int data)
{
    IOWR(GRTOS_DRIVER_GRTOS_MONITOR_BASE, 0, data);
}

/*****************************************************************************/
/*****************************************************************************/
/**         DEBUG MONITOR VARIABLES                                          */
/**         COPY MIRROR OF SYSTEM VARIABLES                                  */
/*****************************************************************************/
/*****************************************************************************/

void gk_RST_MONITOR_HANDLER (void)
{
    IOWR_GRTOS_RST_CLR(GRTOS_CMD_PRC_ID);
    while(1)
    {

        // FILE* fp; PRINT_DEBUG_LINE
        // fp = fopen ("/dev/jtag_uart_1", "r+"); PRINT_DEBUG_LINE //Open file for reading and writing
        // if (fp)
        // {
        //     fprintf(fp, "Closing the JTAG UART file handle.\n"); PRINT_DEBUG_LINE
        //     fclose (fp); PRINT_DEBUG_LINE
        // }
    }

}


/**
 * Returns G_TRUE if points to a TCB
 * @param ptcb pointer to ECB structure to check
 * @return G_TRUE if pointer to ECB, G_FALSE otherwise
 */
INT32 TCB_IsValid(GS_TCB *ptcb)
{
    if (ptcb->BLOCK_HASH == (unsigned int) ptcb + 1) return(G_TRUE);
    return(G_FALSE);
}


INT32 PCB_IsValid(GS_PCB *ppcb)
{
	int processor;

    if (ppcb == (struct gs_pcb *) 0) return(G_TRUE);
	/* Si apunta fuera del arreglo de TCBs retorno G_FALSE */
	if (ppcb > g_kcb.G_PCBTbl + G_NUMBER_OF_PCB * sizeof(GS_PCB)) return(G_FALSE);
	/* Si apunta a una direccion antes del arreglo TCBs retorno G_FALSE */
	if (ppcb < g_kcb.G_PCBTbl) return(G_FALSE);

    /* Obtengo el indice de la tarea */
	processor = (int) ppcb - (int) g_kcb.G_PCBTbl;
	processor = (int) processor / sizeof(GS_PCB);
	processor = (processor * sizeof(GS_PCB)) + (int) g_kcb.G_PCBTbl;
	/* Si el indice apunta a un TCB retorno G_TRUE, si no G_FALSE */
	if (processor != (int) ppcb) return(G_FALSE);
	else return(G_TRUE);
}


/**
 *  \brief Returns G_TRUE is pointer points to ECB
 *  
 *  \param [in] pevent pointer to ECB
 *  \return G_TRUE if pointer to ECB, G_FALSE otherwise 
 */
INT32 ECB_IsValid(GS_ECB *pevent)
{
    if (pevent->BLOCK_HASH == (unsigned int) pevent + 2) return(G_TRUE);
    return(G_FALSE);
}

/**
 *  \brief 
 *  Returns G_TRUE is pointer points to SCB
 *  \param [in] pscb Pointer to SCB to validate
 *  \return G_TRUE when points to a valid SCB, G_FALSE otherwise
 *  
 *  \details 
 *  \todo
 *  \relates Validation
 */ 
INT32 SCB_IsValid(GS_SCB *pscb)
{
    if (pscb->BLOCK_HASH == (unsigned int) pscb + 4) return(G_TRUE);
    return(G_FALSE);
}

 
/**RCB_IsValid
 *  \brief 
 *  Returns G_TRUE is pointer points to RCB
 *  \param [in] prcb Pointer to the RCB of the resource
 *  \return G_TRUE if pointer to SCB, G_FALSE otherwise
 *  \todo Find a way to determine validity when it is not an array
 *  \relates Resource
 */ 
INT32 RCB_IsValid(void *prcb)
{
    if (((G_RCB *) prcb)->BLOCK_HASH == (unsigned int) prcb + 3) return(G_TRUE);
    return(G_FALSE);
}


/**RRDS_IsValid
 *  \brief 
 *  Returns G_TRUE is pointer points to GS_RRDS
 *  \param [in] prrds Pointer to the RRDS
 *  \return G_TRUE if pointer to RRDS, G_FALSE otherwise
 *  \todo Find a way when it is not an array of control blocks
 *  \relates RRDS
 */ 
INT32 RRDS_IsValid(GS_RRDS *prrds)
{
    if (prrds->BLOCK_HASH == (unsigned int) prrds + 5) return(G_TRUE);
    return(G_FALSE);
}



INT32 LCB_IsValid(GS_LCB *plcb)
{
    return(G_TRUE);
    if (plcb->BLOCK_HASH == (unsigned int) plcb + 6) return(G_TRUE);
    return(G_FALSE);    
}

INT32 IsAListorNull(GS_LCB *plcb)
{
	int lcb;
	/* si es puntero nulo retorno G_TRUE */
	if (plcb == (struct gs_lcb *) 0) return(G_TRUE);
    if (plcb->BLOCK_HASH == (unsigned int) plcb + 6) return(G_TRUE);
    return(G_FALSE);     
}

INT32 TCBState_Valid(unsigned int tcbstate)
{
    if (tcbstate == G_TASK_STATE_WAITING_COMPLETED) return G_TRUE;
    if (tcbstate == G_TASK_STATE_READY) return G_TRUE;
    if (tcbstate == G_TASK_STATE_RUNNING) return G_TRUE;
    if (tcbstate == G_TASK_STATE_FREE) return G_TRUE;
    if (tcbstate == G_TASK_STATE_UNLINKED) return G_TRUE;    
    if (tcbstate == G_TASK_STATE_WAITING) return G_TRUE;  
    return G_FALSE;
}

INT32 TCBType_Valid(unsigned int tcbtype)
{
    if (tcbtype == G_TASK_TYPE_UCOS) return G_TRUE;    
    if (tcbtype == G_TASK_TYPE_PERIODIC) return G_TRUE;
    if (tcbtype == G_TASK_TYPE_ISR) return G_TRUE;
    if (tcbtype == G_TASK_TYPE_IDLE) return G_TRUE;
    if (tcbtype == G_TASK_TYPE_UNDEFINED) return G_TRUE;    
    return G_FALSE;
}

INT32 ECBState_Valid(unsigned int ecbstate)
{
    if (ecbstate == GS_ECB_STATE_GRANTED_RESOURCE) return G_TRUE;
    if (ecbstate == GS_ECB_STATE_WAITING_RESOURCE) return G_TRUE;
    if (ecbstate == GS_ECB_STATE_FREE) return G_TRUE;
    if (ecbstate == GS_ECB_STATE_WAITING_TIME) return G_TRUE;
    if (ecbstate == GS_ECB_STATE_UNLINKED) return G_TRUE;    
    return G_FALSE;
}

INT32 ECBType_Valid(unsigned int ecbtype)
{
    if (ecbtype == G_ECB_TYPE_OSTimeDly) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_PERIODIC) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_LASTEST_TIME) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_TIMEOUT_SEM_GRANTED) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_TIMEOUT_SEM_WAITING) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_SEM_GRANTED) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_SEM_WAITING) return G_TRUE;
    if (ecbtype == G_ECB_TYPE_NOT_SPECIFIED) return G_TRUE;    
    return G_FALSE;
}

INT32 PCBID_Valid(int pcbid)
{
    if ((pcbid <= G_NUMBER_OF_PCB) && (pcbid >= 0)) return G_TRUE;
    return G_FALSE;
}

INT32 PCBState_Valid(int pcbstate)
{
    if (pcbstate == GS_PCB_STATE_NOTRUNNING) return G_TRUE;
    if (pcbstate == GS_PCB_STATE_RUNNING) return G_TRUE;
    if (pcbstate == GS_PCB_STATE_FREE) return G_TRUE;       
    return G_FALSE;
}

INT32 PCBType_Valid(int pcbtype)
{ 
    return G_TRUE;
}


INT32 LCBState_IsValid(INT32 lcbstate)
{
    if (lcbstate == GS_LCB_STATE_LINKED) return G_TRUE;
    if (lcbstate == GS_LCB_STATE_UNLINKED) return G_TRUE;  
    return G_FALSE;    
}

INT32 LCBType_IsValid(INT32 lcbtype)
{ 
    return G_TRUE;    
}




OPTIMEZE_RESTORE